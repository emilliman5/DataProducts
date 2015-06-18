library(lubridate)
library(fields)
library(maps)
library(RColorBrewer)
library(calibrate)
data(us.cities)

x<--85.5
y<-45
rad<-250

obs.summary<-read.table("UFO_aggregate_sightings.txt", header=T)
obs<-read.csv("UFO_sightings.txt")

obs[,"Date"]<-as.Date(as.character(obs[,"Date"]))

obs2<-merge(obs, obs.summary)
 
write.csv(obs2,"UFO_sighting_US.txt")   
map("usa")
map("state", col="black",fill=F, add=T, lty=1, lwd=0.5)
map.cities(us.cities,minpop = 500000, cex=1.5, pch=19, col="blue")
points(-85, 45, col="red",pch=18)
n=10

plotCircle(-85,45,150)

my_palette<-colorRampPalette(rev(brewer.pal(5, "YlGnBu")))(n=n-1)
points(obs.summary$long,obs.summary$lat, pch=19,cex=0.2, col=my_palette)


d<-rdist.earth(matrix(c(x,y),nrow=1), data.matrix(obs.summary[, c("long","lat")]))
d2<-rdist.earth(matrix(c(x,y),nrow=1), data.matrix(obs2[, c("long","lat")]))
use<-which(d<=rad)
use2<-which(d2<=rad)
    
p<-sum(obs.summary[use,"freq"])/sum(obs.summary[,"freq"])


