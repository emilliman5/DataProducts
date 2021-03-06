library(XML)
library(RCurl)
library(ggmap)
library(parallel)
library(httr)
library(rjson)

base<-"http://www.nuforc.org/webreports/"
theurl<-"http://www.nuforc.org/webreports/ndxevent.html"
ufos <- getURL(theurl)
ufos <- htmlParse(ufos, encoding = "UTF-8")
titles  <- xpathSApply (ufos ,"//a/@href") 
titles<-titles[c(-1,-length(titles))]

tables <- mclapply(titles, mc.cores = 10, function(x) readHTMLTable(paste0(base,x)))
obs<-do.call(rbind, lapply(tables, as.data.frame))
free(ufos)

colnames(obs)<-gsub("NULL.","", colnames(obs))
#obs<-obs[-which(obs$Date...Time == ""),]
obs[,"Date"]<-as.Date(do.call(rbind,strsplit(as.character(obs$Date...Time), " "))[,1], "%m/%d/%y")
obs<-obs[obs[,"Date"]<=as.Date("2015-06-06"),]


obs<-obs[,c(8,2,3,4,5,6)]
obs$City<-as.character(obs$City)
obs$State<-as.character(obs$State)
obs$City<-gsub("[/\\(].*","",obs$City, perl=T)
obs$City<-gsub("^\\s+|\\s+$","",obs$City, perl=T)
obs$locale<-paste(obs$City, obs$State, sep=",")
obs$locale<-gsub("\\\"","", obs$locale)

write.csv(obs, "UFO_sightings.txt", row.names = F, quote=T)

locations<-unique(obs$locale)

########Geocoding Cities from DataScienceToolkit.org
data <- paste0("[",paste(paste0("\"",locations,"\""),collapse=","),"]")
url  <- "http://www.datasciencetoolkit.org/street2coordinates"
response <- POST(url,body=data)
json     <- fromJSON(content(response,type="text"))
geocodes  <- do.call(rbind,sapply(json,
                        function(x) c(long=x$longitude,lat=x$latitude)))

geocodes<-as.data.frame(geocodes)
geocodes$query<-rownames(geocodes)
rownames(geocodes)<-seq(1,length(geocodes[,1]))

write.csv(geocodes[,c(3,1,2)], "geocodes_DSTK.txt", quote = T, row.names=F)

##########

obs<-merge(obs, geocodes, by.x="locale", by.y = "query", all.x=T)
obsUS<-obs[!is.na(obs[,"long"]),]


obs.summary<-aggregate(locale~long+lat, data = obsUS, length)

write.csv(obsUS, "UFO_sighting_US.txt",row.names = F, quote=T)
write.csv(obs.summary, "UFO_aggregate_sightings.txt", quote=T,row.names = F)


# ##Google Maps API call, limited to 2500 requests per 24hrs.
# x<-lapply(locations[4401:5000],function(x) y<- tryCatch(geocode(x, output = c("more")),
#               warning = function(w) {
#                 print("warning"); 
#                 # handle warning here
#               },
#               error = function(e) {
#                 print("error")
#               }))
# tmp<-do.call(rbind, x)
# ##
