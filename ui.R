library(shiny)

shinyUI(pageWithSidebar(
  headerPanel("UFO Sightings in the USA"),
  sidebarPanel(
    h2("Enter a location:"),
    numericInput("lat","Latitude", 45.0, min=25, max=90),
    numericInput("long", "Longitude", -100, min=-126, max=-60),
    sliderInput("rad", "Radius (mi)", min=1, max=500, value=150),
    h3("Number of Records to Return:"),
    numericInput("n","Records", 15, min=0, max=1000),
    submitButton("Submit"),
    h2("Sightings in your vicinity"),
    h4("You entered:"),
    verbatimTextOutput("inputValue"),
    h4("The chance you will see a UFO at this location is:"),
    verbatimTextOutput("prediction")
  ),
  mainPanel(
    h3("Introduction"),
    p("This sight is designed to let you explore reported UFO sightings in the USA 
      (the rest of the world will be added at a later time). Data was obtained from the National 
      UFO Reporting Center's Website", a("http://nuforc.org"), ". There have been ~78,000 reports 
      of UFO sightings across ~16,000 geographical locations in continental US, dating back to the 1960's. 
      Questions, Comments and Concerns can be directed to me at", a("http://github.com/emilliman5")),
    plotOutput("map"),
    plotOutput("trend"),
    plotOutput("trendNormal"),
    tableOutput("view"),
    h3("Acknowledgements"),
    p("UFO sightings data was obtained from the National UFO reporting center",
    a("http://www.nuforc.org"),
    "The locations from the sightings data was gecoded using the DataScientists ToolKit",
    a("http://www.datasciencetoolkit.org"),
    "and Google Maps API servie and ggmap, D. Kahle and H. Wickham. ggmap: Spatial Visualization with ggplot2. The R Journal, 5(1), 144-161.",
    a("http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf"))
    )
))