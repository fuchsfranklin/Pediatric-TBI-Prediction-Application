###################################################################
# Environment Setup
###################################################################
library(devtools)
library(shiny)
library(shinythemes)
library(ggplot2)
library(gganimate)
library(shinycustomloader)
library(transformr)
library(tidyr)
library(gifski)
library(caret)      
library(class)      
library(mltools)    
library(ROCR)      
library(pROC)      
#library(DMwR, lib.loc = "4.0")       
library(C50)   

###################################################################
# UI
###################################################################
theme_set(theme_bw())

ui <- navbarPage(theme = shinytheme("simplex"),
                 
                 title = "Traumatic Brain Injury (TBI) Mortality Prediction Web-Application",
                 
###################################################################
# Main Tab
###################################################################                
                 tabPanel(title = "(For US-based Pediatric TBI Patients)",
                          tags$ul(
                            tags$li("Enter patient information below and press the \"Predict\" button to return a mortality prediction and an associated probability between 0% and 100%."),
                          ),
                          
                          sidebarLayout(
                            position = "left",
                            sidebarPanel(align="center",
                              tags$h3("Patient Information"),
                              fluidRow(
                                column(4,selectInput("gender", "Gender",
                                                     c("Male" = "male",
                                                       "Female" = "female"))),
                                column(4,selectInput("type", "Injury Type",
                                                     c("Penetrating" = "pen",
                                                       "Blunt" = "blu",
                                                       "Other" = "oth"))),
                                column(4,selectInput("race", "Race",
                                                     c("American Indian" = "ind",
                                                       "Asian"= "asi",
                                                       "Pacific Islander" = "pac",
                                                       "Caucasian" = "cau",
                                                       "Other" = "oth")))

                              ),
                              fluidRow(
                                column(4,selectInput("suppox", "Supplemental Oxygen Use",
                                                     c("Yes" = 1,
                                                       "No" = 0))),
                                column(4,selectInput("drug", "Drug Use",
                                                     c("Yes" = 1,
                                                       "No" = 0))),
                                column(4,selectInput("alc", "Alcohol Use",
                                                     c("Yes" = 1,
                                                       "No" = 0)))
                              ),
                              fluidRow(
                                column(4,numericInput(inputId="ais",
                                                      label=withMathJax(sprintf("Abbreviated Injury Scale (AIS)")),
                                                      value=1)),
                                column(4,numericInput(inputId="iss",
                                                      label=withMathJax(sprintf("Injury Severity Score (ISS)")),
                                                      value=1)),
                                column(4,numericInput(inputId="gcs",
                                                      label=withMathJax(sprintf("Glasgow Coma Scale (GCS)")),
                                                      value=3))
                              ),
                              fluidRow(
                                column(4,numericInput(inputId="age",
                                                      label=withMathJax(sprintf("Age (Years)")),
                                                      value=0)),
                                column(4,numericInput(inputId="sbp",
                                                      label=withMathJax(sprintf("Systolic Blood Pressure (mmHg)")),
                                                      value=0)),
                                column(4,numericInput(inputId="pulse",
                                                      label=withMathJax(sprintf("Pulse Rate (mmHg)")),
                                                      value=0))
                              ),
                              fluidRow(
                                column(4,numericInput(inputId="rr",
                                                      label=withMathJax(sprintf("Respiratory Rate (bpm)")),
                                                      value=0)),
                                column(4,numericInput(inputId="os",
                                                      label=withMathJax(sprintf("Oxygen Saturation (%%)")),
                                                      value=0)),
                                column(4,numericInput(inputId="temp",
                                                      label=withMathJax(sprintf("Body Temperature (\\(^\\circ\\)C)")),
                                                      value=0))
                              ),
                              actionButton(inputId="go",
                                           label="Predict"),
                             width = 8 ),
                            mainPanel(align="center",
                                      div(" ",
                                        style = "height: 20px; width: 200px;"
                                      ),
                                      tags$h3("Result"),
                                      h4(strong(textOutput("text")))
                            , width = 4)
                          )
                 ),
            fluid=FALSE                 
)

###################################################################
#Server
###################################################################
server <- function(input, output) {
  
  text_reactive <- eventReactive(input$go,
            {
              load("c50_smote.Rdata")
              load("singlei_str.RData")
              new_obs <- test[0,]
              
              new_obs$Death.within.14.days <- NULL
              
              race_num <- c(0,0,0,0,0)
              race_choice <- switch(input$race, 
                              "ind" = 1,
                              "asi" = 2,
                              "pac" = 3,
                              "cau" = 5,
                              "oth" = 4)
              race_num[race_choice] <- 1
              
              type_num <- c(0,0,0)
              type_choice <- switch(input$type, 
                                    "pen" = 2,
                                    "blu" = 3,
                                    "oth" = 1)
              type_num[type_choice] <- 1
              
              gender_num <- ifelse(input$gender=="male",1 , 0)
              
              suppox_num <- ifelse(input$suppox=="yes", 1 , 0)
              
              new_obs[1,] <- c(input$ais               ,  #AIS
                               input$age               ,  #Age
                               gender_num              ,  #Gender
                               input$iss               ,  #ISS
                               input$sbp               ,  #SBP
                               input$pulse             ,  #Pulse
                               input$rr                ,  #RR
                               input$os                ,  #Oxysat
                               input$temp              ,  #Temp
                               suppox_num              ,  #Suppoxy
                               input$gcs               ,  #Gcstot      
                               race_num[1]             ,  #Race.American.Indian
                               race_num[2]             ,  #Race.Asian  
                               race_num[3]             ,  #Race.Hawaiian 
                               race_num[4]             ,  #Race.Other.Race 
                               race_num[5]             ,  #Race.White
                               type_num[1]             ,  #Type.Other
                               type_num[2]                #Type.Penetrating
              )
              
              model_prob <- predict(model_smote_roc,newdata=new_obs[1,],type = "prob")   
              
              sprintf(paste("The patient was predicted as a",
                            model_prob[1,1],
                            ifelse(model_prob[1,1]=="case","(non-survivor)","(survivor)"),
                            "with a mortality probability of",
                            paste(toString(round(model_prob[1,2]*100, digits = 2)),"%%.",sep=""))
              )
        }
    )
  
  output$text <- renderText({
    text_reactive()
  })
}

###################################################################
#App Construction
###################################################################
shinyApp(server = server, ui = ui)