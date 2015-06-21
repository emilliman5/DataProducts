library(shiny)
library(fields)
library(ggplot2)
library(lubridate)

plotCircle <- function(LonDec, LatDec, Mi) {#Corrected function
    #LatDec = latitude in decimal degrees of the center of the circle
    #LonDec = longitude in decimal degrees
    #Km = radius of the circle in kilometers
    ER <- 3959 #Mean Earth radius in miles.
    AngDeg <- seq(1:360) #angles in degrees 
    Lat1Rad <- LatDec*(pi/180)#Latitude of the center of the circle in radians
    Lon1Rad <- LonDec*(pi/180)#Longitude of the center of the circle in radians
    AngRad <- AngDeg*(pi/180)#angles in radians
    Lat2Rad <-asin(sin(Lat1Rad)*cos(Mi/ER)+cos(Lat1Rad)*sin(Mi/ER)*cos(AngRad)) #Latitude of each point of the circle rearding to angle in radians
    Lon2Rad <- Lon1Rad+atan2(sin(AngRad)*sin(Mi/ER)*cos(Lat1Rad),cos(Mi/ER)-sin(Lat1Rad)*sin(Lat2Rad))#Longitude of each point of the circle rearding to angle in radians
    Lat2Deg <- Lat2Rad*(180/pi)#Latitude of each point of the circle rearding to angle in degrees (conversion of radians to degrees deg = rad*(180/pi) )
    Lon2Deg <- Lon2Rad*(180/pi)#Longitude of each point of the circle rearding to angle in degrees (conversion of radians to degrees deg = rad*(180/pi) )
    c<-data.frame(Lon2Deg,Lat2Deg)
    c
}

sightings<-read.csv("UFO_sighting_US.txt")
sightings[,"Date"]<-as.Date.factor(sightings[,"Date"])
aggSightings<-read.csv("UFO_aggregate_sightings.txt", header=T)
states<-map_data("state")
aggSightings<-aggSightings[aggSightings[,"long"]>=range(states$long)[1] & aggSightings[,"long"]<=range(states$long)[2] &
                           aggSightings[,"lat"]>=range(states$lat)[1] & aggSightings[,"lat"]>=range(states$lat)[1], ]
percent <- function(x, digits = 2, format = "f", ...) {
  paste0(formatC(100 * x, format = format, digits = digits, ...), "%")
}

ufoPred<-function(y, x, r){
    d<-rdist.earth(matrix(c(x,y),nrow=1), data.matrix(aggSightings[, c("long","lat")]))
    use<-which(d<=r)
    percent(sum(aggSightings[use,"locale"])/sum(aggSightings[,"locale"]))
}

ufoTable<-function(y,x,r){
    d2<-rdist.earth(matrix(c(x,y),nrow=1), data.matrix(sightings[, c("long","lat")]))
    use2<-which(d2<=r)
    use2
}

sightingsAgg<-function(u){
    aggregate(sightings[u,2],by = list(year(sightings[u,"Date"])), length)
}

sightingsNormal<-function(u){
  a<-aggregate(sightings[u,2],by = list(year(sightings[u,"Date"])), length)
  t<-aggregate(sightings[year(sightings[,"Date"]) %in% a$Group.1,2], by=list(year(sightings[year(sightings[,"Date"]) %in% a$Group.1,"Date"]))
                              ,length)
  s<-cbind(a$Group.1, a$x/t$x)
  s
}

shinyServer(
  function(input, output){
    output$inputValue<-renderPrint({c(input$lat, input$long)})
    output$prediction<-renderPrint({ufoPred(input$lat, input$long, input$rad)})
    coord<-reactive({data.frame(input$long, input$lat)})
    output$map<-renderPlot({
       ggplot()+geom_polygon(data=states, aes(long, lat, group=group), colour="black",fill="grey") +
       stat_density2d(data=aggSightings, aes(x=long, y=lat, fill=..level.., alpha=..level..),
                             size=1, bins=15, geom='polygon') + scale_fill_gradient(low = "green",high="red") + 
        scale_alpha(range=c(0.1,0.5), guide=F) +
        geom_point(aes_string(input$long, input$lat), colour="red",size=4) +
        geom_polygon(data=plotCircle(input$long, input$lat, input$rad),aes(Lon2Deg,Lat2Deg), colour="red",alpha=0)
       })
    u<-reactive({ufoTable(input$lat, input$long, input$rad)})
    output$trend<-renderPlot({
      plot(aggregate(sightings[u(),"City"], 
                     list(year(sightings[u(),"Date"])),length), 
           pch=19, type="b", xlab="Year",ylab="Number of Sightings", main="Sightings per Year")
      })
    output$trendNormal<-renderPlot({
      plot(sightingsNormal(u()), 
           pch=19, type="b", xlab="Year",ylab="Fraction of Sightings", 
           main="Fraction of Total Sightings per Year")
    })
    output$view<-renderTable({
      cbind(as.character(sightings[u(),"Date"]), sightings[u(),
                     c("City","State","Duration","Shape","Summary")])[1:input$n,]})
    }
)



