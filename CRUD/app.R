library(shiny)
library(mongolite)
library(dplyr)
library(DT)
library(tidyr)
library(shinyalert)


# Define UI for application that draws a histogram
ui <- navbarPage("MongoDB and R",
         tabPanel("CRUD",
            fluidPage(
        
            # Application title
            titlePanel("CRUD Operations - MDB Movies Dataset"),
        
            # Sidebar with a slider input for number of bins 
            sidebarLayout(
                sidebarPanel(
                    sliderInput("rating",
                                "Min Rating",
                                min = 1,
                                max = 10,
                                value = c(3,5)
                                ),
                    textInput("movie_name",
                              "Movie Name",
                              "Movie Name"),
                    numericInput("movie_rating",
                                 label="Movie Rating",
                                 min=0,
                                 value=3,
                                 max=10,
                                 step=0.1),
                    actionButton("add_movie","Add Movie"),
                    actionButton("update_movie","Update Movie"),
                    actionButton("delete_movie","Delete Movie"),
                    actionButton("refresh","Refresh")
                ),
                # Show a plot of the generated distribution
                mainPanel(
                    dataTableOutput("best_movies"),
                    textOutput("text")
                )
            )
        )
    ),
    tabPanel("Visualization",
             fluidPage(
                 
                 # Application title
                 titlePanel("AirBnB Simulation"),
                 
                 # Sidebar with a slider input for number of bins 
                 sidebarLayout(
                     sidebarPanel(
                         sliderInput("beds",
                                     "Number Beds",
                                     min = 1,
                                     max = 10,
                                     value = c(3,5)
                         ),
                         sliderInput("review_score",
                                     "Range Review Scores",
                                     min = 0,
                                     max = 100,
                                     value = c(3,5)
                         ),
                         actionButton("build_model","Build Model"),
                         actionButton("visualize_simulation","Simulate")
                     ),
                     # Show a plot of the generated distribution
                     mainPanel(
                         textOutput("analytics_text"),
                         textOutput("analytics_data"),
                         plotOutput("simulation_plot",width = "100%", height = "700px"),
                         textOutput("analytics_prices")
                     )
                 )
             )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    #MongoDB
    options(mongodb = list(
        "username" = "Username",
        "password" = "Password",
        "url" = "ConnectionString"
    ))

    #mongolite - macht aus jeder Zeile des Dataframes ein Dokument
    # -> dabei werden Listen zu Arrays, nested Documents werden nicht eingesetzt
    databaseName <- "sample_mflix"
    collectionName <- "movies"

    db <- mongo(collection = collectionName,
                url = options()$mongodb$url,
                db = databaseName)

    lower <- reactive(input$rating[1])
    upper <- reactive(input$rating[2])
    
    output$best_movies <- renderDataTable({
        aggregation <- paste0('[{"$match": {"$and": [{"imdb.rating": {"$gte":',lower(),'}},
                              {"imdb.rating":{"$lte":', upper(),'}}]}}, 
                              {"$project": {"title":1,"rating": "$imdb.rating"}}]')
        res <- db$aggregate(aggregation)
        res <- res %>% 
            arrange(desc(rating)) %>% 
            select(title,rating)
        DT::datatable(res,options=list(pageLength = 5))
    })
    
    observeEvent(input$refresh,{
        output$best_movies <- renderDataTable({
            aggregation <- paste0('[{"$match": {"$and": [{"imdb.rating": {"$gte":',lower(),'}},
                                  {"imdb.rating":{"$lte":', upper(),'}}]}}, 
                                  {"$project": {"title":1,"rating": "$imdb.rating"}}]')
            res <- db$aggregate(aggregation)
            res <- res %>% 
                arrange(desc(rating)) %>% 
                select(title,rating)
            DT::datatable(res,options=list(pageLength = 5))
        })
    })
    
    output$text <- renderText({
        paste0("Running: ",aggregation)
    })
    
    observeEvent(input$add_movie,{
        db$insert(paste0('{"title":"',input$movie_name,'","imdb":{"rating":',input$movie_rating,'}}'))
    })
    
    observeEvent(input$update_movie,{
        db$update(paste0('{"title":"',input$movie_name,'"}'),paste0('{"$set":{"imdb":{"rating":',input$movie_rating,'}}}'))
    })
    
    observeEvent(input$delete_movie, {
        shinyalert(input$movie_name, "Has beed permanently removed from the database.", type = "error")
        db$remove(paste0('{"title":"', input$movie_name,'"}'), just_one = TRUE)
    })
    
    
    
    
    
    #Data Analytics & Viz
    analyticsDatabaseName <- "sample_airbnb"
    analyticsCollectionName <- "listingsAndReviews"
    
    analytics_db <- mongo(collection = analyticsCollectionName,
                            url = options()$mongodb$url,
                            db = analyticsDatabaseName)
    aggregation <- paste0('
    [{"$match": {
        "$and": [
            {"monthly_price": {"$exists": "true"}},
            {"review_scores.review_scores_value": {"$exists":"true"}}
            ]
    }}, {"$project": {
        "_id": 0,
        "monthly_rent": "$monthly_price",
        "beds": "$beds",
        "review_score": "$review_scores.review_scores_value"
    }}]'
    )
    res <- analytics_db$aggregate(aggregation)
    
    #build the model:
    library(rpart)
    library(scatterplot3d)
    
    global_values <- reactiveValues()
    
    observeEvent(input$build_model, {
        global_values$fit <- rpart(monthly_rent~., 
                     data = res,
                     control = rpart.control(minsplit = 5)
        )
        
        output$analytics_text <- renderText({
            paste0("Model-Summary: ","model build complete")
        })
    })
    
    #User Input:
    beds_lower <- reactive(input$beds[1])
    beds_upper <- reactive(input$beds[2])
    
    review_score_lower <- reactive(input$review_score[1])
    review_score_upper <- reactive(input$review_score[2])
    
    observeEvent(input$visualize_simulation, {
        
        beds <- seq(beds_lower(),beds_upper(),by=1)
        review_score <- seq(review_score_lower(),review_score_upper(),by=1)
        sim_data <- expand.grid(beds = beds, review_score = review_score)
        
        fit <- global_values$fit
        prices <- predict(fit,sim_data)
        
        output$simulation_plot <- renderPlot({
            s3d <- scatterplot3d(x = sim_data$beds,
                                 y = sim_data$review_score,
                                 z = prices, type = "h", color = hsv(seq(0.3, 1, length = dim(sim_data)[1])),
                                 angle=55, pch = 16)
            my.lm <- lm(prices ~ sim_data$beds + sim_data$review_score)
            s3d$plane3d(my.lm)
        })
        output$analytics_prices <- renderText({
            prices
        })
    })
}


# Run the application 
shinyApp(ui = ui, server = server)
