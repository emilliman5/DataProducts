library(shiny)
library(fields)
library(maps)
library(calibrate)
library(lubridate)

plotCircle <- function(LonDec, LatDec, Mi) {#Corrected function
    #LatDec = latitude in decimal degrees of the center of the circle
    #LonDec = longitude in decimal degrees
    #Km = radius of the circle in kilometers
    ER <- 3959 #Mean Earth radius in kilometers. Change this to 3959 and you will have your function working in miles.
    AngDeg <- seq(1:360) #angles in degrees 
    Lat1Rad <- LatDec*(pi/180)#Latitude of the center of the circle in radians
    Lon1Rad <- LonDec*(pi/180)#Longitude of the center of the circle in radians
    AngRad <- AngDeg*(pi/180)#angles in radians
    Lat2Rad <-asin(sin(Lat1Rad)*cos(Mi/ER)+cos(Lat1Rad)*sin(Mi/ER)*cos(AngRad)) #Latitude of each point of the circle rearding to angle in radians
    Lon2Rad <- Lon1Rad+atan2(sin(AngRad)*sin(Mi/ER)*cos(Lat1Rad),cos(Mi/ER)-sin(Lat1Rad)*sin(Lat2Rad))#Longitude of each point of the circle rearding to angle in radians
    Lat2Deg <- Lat2Rad*(180/pi)#Latitude of each point of the circle rearding to angle in degrees (conversion of radians to degrees deg = rad*(180/pi) )
    Lon2Deg <- Lon2Rad*(180/pi)#Longitude of each point of the circle rearding to angle in degrees (conversion of radians to degrees deg = rad*(180/pi) )
    polygon(Lon2Deg,Lat2Deg,lty=2)
}

sightings<-read.csv("UFO_sighting_US.txt")
aggSightings<-read.table("UFO_aggregate_sightings.txt", header=T)

ufoPred<-function(y, x, r){
    d<-rdist.earth(matrix(c(x,y),nrow=1), data.matrix(aggSightings[, c("long","lat")]))
    use<-which(d<=r)
    sum(aggSightings[use,"freq"])/sum(aggSightings[,"freq"])
    
}

ufoTable<-function(y,x,r){
    d2<-rdist.earth(matrix(c(x,y),nrow=1), data.matrix(sightings[, c("long","lat")]))
    use2<-which(d2<=r)
    use2
}

sightingsAgg<-function(u){
    aggregate(sightings[u,2],by = list(year(sightings[u,"Date"])), length)
}

shinyServer(
  function(input, output){
    output$inputValue<-renderPrint({c(input$lat, input$long)})
    output$prediction<-renderPrint({ufoPred(input$lat, input$long, input$rad)})
    output$map<-renderPlot({
      map("usa")
      map("state", col="black",fill=F, add=T, lty=1, lwd=0.5)
      points(input$long,input$lat, col="red", pch=19)
      text(input$long,input$lat+1, "You are Here")
      plotCircle(input$long,input$lat, input$rad)
      })
    output$trend<-renderPlot({
      plot(aggregate(sightings[ufoTable(input$lat, input$long, input$rad),"City"], 
                     list(year(sightings[ufoTable(input$lat, input$long, input$rad),"Date"])),length), pch=19, type="b", xlab="Year",ylab="Number of Sightings")
    })
    output$view<-renderTable({
      head(sightings[ufoTable(input$lat, input$long, input$rad),
                     c("Date","City","State","Duration","Shape","Summary")], input$n)})
    }
)