library(XML)
library(RCurl)
library(ggmap)
library(parallel)
library(lubridate)
library(fields)
library(maps)

date<-as.Date("01/01/10", "%d/%m/%Y")

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
obs[,"Date"]<-as.Date(do.call(rbind,strsplit(as.character(obs$Date...Time), " "))[,1], "%m/%d/%Y")

obs<-obs[,c(8,2,3,4,5,6)]
obs$City<-as.character(obs$City)
obs$State<-as.character(obs$State)
obs$City<-gsub("[/\\(].*","",obs$City, perl=T)

locations<-unique(paste(obs$City, obs$State, sep=","))

geocodes<-us.cities[us.cities$name %in% locations,]
locations<-locations[!(locations %in% us.cities$name)]

##locations[1:1900]

x<-lapply(locations[1:1900],function(x) y<- tryCatch(geocode(x, output = c("more")),
              warning = function(w) {
                print("warning"); 
                # handle warning here
              },
              error = function(e) {
                print("error")
              }))
tmp<-do.call(rbind, x)
write.table(tmp, "geocodes_1-1900.txt", sep="\t",quote=F,row.names=F)
