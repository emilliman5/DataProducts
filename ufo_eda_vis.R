library(fields)
library(maps)
library(RColorBrewer)
library(mapproj)
library(ggplot2)
library(ggmap)

states<-map_data("state")

x<--85.5
y<-45
rad<-250

obs.summary<-read.csv("UFO_aggregate_sightings.txt", header=T)
obs<-read.csv("UFO_sighting_US.txt", header=T)
obs[,"Date"]<-as.Date(as.character(obs[,"Date"]))
obs.summary<-obs.summary[obs.summary[,"long"]>=range(states$long)[1] & obs.summary[,"long"]<=range(states$long)[2] &
                           obs.summary[,"lat"]>=range(states$lat)[1] & obs.summary[,"lat"]>=range(states$lat)[1], ]
# write.csv(obs2,"UFO_sighting_US.txt")   

d<-rdist.earth(matrix(c(x,y),nrow=1), data.matrix(obs.summary[, c("long","lat")]))
d2<-rdist.earth(matrix(c(x,y),nrow=1), data.matrix(obs2[, c("long","lat")]))
use<-which(d<=rad)
use2<-which(d2<=rad)

map('usa')
map("state", col="black",fill=F, add=T, lty=1, lwd=0.5)
map.grid(nx = 5, ny=5 ,labels = F)
map.axes()
map.cities(us.cities,minpop = 500000, cex=1, pch=19, col="blue",label = T, cex.lab=0.75)
points(-85, 45, col="red",pch=18)
plotCircle(-85,45,150)

points(obs.summary$long,obs.summary$lat, pch=19,cex=0.2, col=my_palette)

tmp<-obs.summary[use2,]
brks <- with(tmp, seq(min(freq), max(freq), length.out = 11))
grps<-with(tmp, cut(freq, breaks=brks, include.lowest = T))
tmp$col<-with(tmp, cut(freq, breaks=brks, include.lowest = T))
my_palette<-colorRampPalette(brewer.pal(9, "YlGnBu"))(length(levels(grps)))

m<-map("usa", plot = F)
plot(m, xlim=c(x-3,x+3), ylim=c(y-3,y+3), type="l")
points(x, y, col="red",pch=18, cex=2)
plotCircle(x,y,150)
points(obs.summary[use,c("long","lat")], col=my_palette, pch=19, cex=0.5)
legend("topright", bty="n", pch=19, col=my_palette, legend=levels(grps), cex=0.75)

p<-sum(obs.summary[use,"freq"])/sum(obs.summary[,"freq"])


us<-get_map('usa', zoom=4)

ggmap(us, extent='device',legend='topright', maprange=F) + 
    stat_density2d(data=obs.summary, aes(x=long, y=lat, fill=..level.., alpha=..level..),
                   size=1, bins=50, geom='polygon') + scale_fill_gradient(low = "green",high="red") + 
    #geom_density2d(data=obs.summary, aes(x=long, y=lat)) +
    scale_alpha(range=c(0.1,0.7), guide=F)
    theme(legend.position="none",axis.title=element_blank(), text=element_text(size=12))

c<-plotCircle(x,y,rad)
    
m<-ggplot()+geom_polygon(data=states, aes(long, lat, group=group), colour="black",fill="grey")
m<-m + stat_density2d(data=obs.summary, aes(x=long, y=lat, fill=..level.., alpha=..level..),
                 size=1, bins=50, geom='polygon') + scale_fill_gradient(low = "green",high="red") + 
  # geom_density2d(data=obs.summary, aes(x=long, y=lat)) +
  scale_alpha(range=c(0.1,0.7), guide=F)+geom_point(aes(x, y), colour="red",size=4) +
  geom_polygon(data=c,aes(Lon2Deg,Lat2Deg), colour="red",alpha=0)
m






