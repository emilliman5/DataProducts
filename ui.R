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
    plotOutput("map"),
    h3("Acknowledgements"),
    p('UFO sightings data was obtained from the National UFO reporting center (http://www.nuforc.org). The locations from the sightings data was gecoded using the DataScientists ToolKit () and Google Maps API servie and ggmap, D. Kahle and H. Wickham. ggmap: Spatial Visualization with ggplot2. The R Journal,
    5(1), 144-161. URL http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf'))
))