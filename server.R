library(shiny)
library(fields)
library(maps)

ufoPred<-function(y, x){
  sum(x,y)
}

shinyServer(
  function(input, output){
    output$inputValue<-renderPrint({c(input$lat, input$long)})
    output$prediction<-renderPrint({ufoPred(input$lat, input$long)})
    output$map<-renderPlot({
      map("usa")
      map("state", col="black",fill=F, add=T, lty=1, lwd=0.5)
      points(input$long,input$lat, col="red", pch=19)
      })
    }
)