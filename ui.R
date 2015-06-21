library(shiny)

shinyUI(pageWithSidebar(
  headerPanel("UFO Sightings in the USA"),
  sidebarPanel(
    h2("Enter a location:"),
    numericInput("lat","Latitude", 45.0, min=25, max=90),
    numericInput("long", "Longitude", -100, min=-126, max=-60),
    p("Adjusting the radius will change how much data is used to predict your chance of sighting and aggregate sighting charts"),
    sliderInput("rad", "Radius (mi)", min=1, max=500, value=150),
    h3("Number of Records to Return:"),
    p("Adjust this number to see more or less of the individual sighting reports."),
    numericInput("n","Records", 15, min=0, max=1000),
    submitButton("Submit"),
    h2(""),
    h4("Your location:"),
    verbatimTextOutput("inputValue"),
    h4("The chance you will see a UFO at this location is:"),
    verbatimTextOutput("prediction")
  ),
  mainPanel(
    h3("Introduction"),
    p("This sight is designed to let you explore reported UFO sightings in the USA 
      (the rest of the world will be added at a later time). Data was obtained from the National 
      UFO Reporting Center's Website", a("nuforc.org.",href="http://nuforc.org"), ". There have been ~78,000 reports 
      of UFO sightings across ~16,000 geographical locations in continental US, dating back to the 1960's. 
      Questions, Comments and Concerns can be directed to me at", a("Github.", href="http://github.com/emilliman5"), "This 
      webpage was built as part of the the John's Hopkins Data Science Specialization Series",a("datasciencespecialization.github.io/",href="http://datasciencespecialization.github.io/"), 
      "at Coursera", a("coursera.org",href="http://coursera.org")),
    plotOutput("map"),
    plotOutput("trend"),
    plotOutput("trendNormal"),
    tableOutput("view"),
    h3("Acknowledgements"),
    p("UFO sightings data was obtained from the National UFO reporting center",
    a("nuforc.org", href="http://www.nuforc.org"),
    "The locations from the sightings data was gecoded using the DataScientists ToolKit",
    a("DataScience ToolKit",href="http://www.datasciencetoolkit.org"),
    "and Google Maps API servie and ggmap, D. Kahle and H. Wickham. ggmap: Spatial Visualization with ggplot2. The R Journal, 5(1), 144-161.",
    a("Kahle and Wickam", href="http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf"))
    )
))