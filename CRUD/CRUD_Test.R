library(mongolite)

options(mongodb = list(
  "username" = "Julian",
  "password" = "Julian1994",
  "url" = "mongodb+srv://Julian:Julian1994@cluster0-hfwvj.mongodb.net/test?retryWrites=true&w=majority"
))

#mongolite - macht aus jeder Zeile des Dataframes ein Dokument 
# -> dabei werden Listen zu Arrays, nested Documents werden nicht eingesetzt

databaseName <- "sample_mflix"
collectionName <- "movies"

saveData <- function(data){
  db <- mongo(collection = collectionName,
              url = options()$mongodb$url,
              db = databaseName)
  #Insert Data into Collection
  data <- as.data.frame(t(data))
  res <- db$insert(data)
  return(res)
}

saveDF <- function(data){
  db <- mongo(collection = collectionName,
              url = options()$mongodb$url,
              db = databaseName)
  #Insert Data into Collection
  res <- db$insert(data)
  return(res)
}

loadData <- function(){
  db <- mongo(url = options()$mongodb$url,
              db = databaseName,
              collection = collectionName)
  #Load Data
  data <- db$find()
  return(data)
}