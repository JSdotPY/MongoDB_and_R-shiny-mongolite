# MongoDB & R-Shiny for Analytics and Reporting

R is a powerful statistical programming language. And even though I am a huge Python fan and advocate I dislike the constant fight about which language is superior and why.
This is why I have prepared a Slide-Deck demonstrating why R and Pyhton
  - Are both relevant
  - Showcase some of the strenghts of R
  - Show how R can leverage MongoDB to overcome some of the barrieres when it comes to working with unstructured and semistructured data

Furthermore, I brought MongoDB into play to show how it makes R even more powerful by allowing me as a DataScientist to work with data in the best and most intuitive way possible. Storing all data that belongs together in the same place and providing me with strong aggregation and transformation capabilities to prepare and preprocess my datasets.

# The Slide-Deck
https://docs.google.com/presentation/d/1U3lUGKrWZmYSVW6bm1IrJPHDFwkYc0hCxDUzdfETFSg/edit?usp=sharing

# The Demo / The Shiny Application
The Demo can be found in the app.R file and it consists of two parts:
- A simply CRUD application
- A ML Showcase, making use of the strong visualization capabilities of R directly in Shiny

**The Crud Application:**<br>
Uses datatables to display a subset of the sample movies data that can be loaded in the free tier of MongoDB Atlas. It is allows to write, update and delete entries in MongoDB directly via the UI


**The ML Application:**<br>
This section is meant to demonstrate how easy it is to make models that use semistructured data directly from MongoDB to build models in R. Furthermore it showcases the similarity in logic that is used to write code in R-Tidyverse and MongoDB Aggregation-Framework.
The Model Build is a Regression Tree, that predicts the monthly rent price given two input variables:
- The score of the property
- The number of beds provided in the flat
It then creates the cartesian product of the two to make a 3D-Visualization of all the possible combinations for the input variables given the input sliders in the UI and plots them using a 3D-Scatter Plot library into the Shiny UI.

### Installation
- Go to http://atlas.mongodb.com and create a free Account.
- Create a Cluster (M0 is free)
- Klick on the three dots next to the connect button on your cluster and choose load sample dataset <br>

Once you have done that and the cluster has finished the initialization / update:
Please Adjust the connection-string to MongoDB Atlas and ensure to have loaded the sample datasets
```sh
    #MongoDB
    options(mongodb = list(
        "username" = "Username",
        "password" = "Password",
        "url" = "Connection-String"
    ))
```
Now you can launch the Shiny-Application from within R-Studio.

### Plugins

| Plugin | README |
| ------ | ------ |
| Shiny | [https://shiny.rstudio.com/][PlDb] |
| MongoLite | [https://jeroen.github.io/mongolite/][PlGh] |


This is a manual comment:
Markdown Created with: https://dillinger.io/
