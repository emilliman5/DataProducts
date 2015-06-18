library(shiny)

shinyUI(pageWithSidebar(
  headerPanel("Vistors from the Final Frontier"),
  sidebarPanel(
    h2("Enter a location:"),
    numericInput("lat","Latitude", 45.0, min=25, max=90),
    numericInput("long", "Longitude", -100, min=-126, max=-60),
    submitButton("Submit"),
    h2("Sightings in your vicinity"),
    h4("You entered:"),
    verbatimTextOutput("inputValue"),
    h4("The chance you will see a UFO sometime this year is:"),
    verbatimTextOutput("prediction")
  ),
  mainPanel(
    plotOutput("map")
    )
))