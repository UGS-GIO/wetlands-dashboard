library(rmarkdown)
library(flexdashboard)
library(shiny)

# Get the port from environment variable or use default
port <- Sys.getenv("PORT")
if(port == "") port <- 5000

# Run the R Markdown document
rmarkdown::run("app.Rmd", 
               shiny_args = list(
                 host = "0.0.0.0",
                 port = as.numeric(port)
               ))