# This is the user-interface definition of a Shiny web application.

library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)


# read miete03 (provided by the lecturer and is unchanged)
housing <- housing <- read.csv('./data/housing.csv', header = TRUE)

# Define UI for application that draws a histogram
fluidPage(
  titlePanel("ShinyApp Stochastik SoSe23 - HTW Berlin FB4 MSC"),
  tabsetPanel(
    
    # Info Tab
    tabPanel("Information",
             mainPanel(
               # Hauptinhalt für Tab 2
             )
    ),
    #### Tab 1 - Confidence Interval ####
    tabPanel("Confidence Interval",
             sidebarLayout(
               sidebarPanel(
                 sliderInput("threshold_range", "Scope", 
                             #min = 0, max = max(housing$households), value = c(0, max(housing$households)),step = 1)
                             min = 0, max = 2000, value = c(0, 2000),step = 1),
                 sliderInput("samplesize", "Sample Size", 10, 50, 10),
                 sliderInput("confidence", "Confidence Level", .9, .99, .9, step = 0.01),
                 actionButton("addButton", "Add Conf.Plot"),
                 actionButton("resetButton", "Reset Conf.Plot")
               ),
               mainPanel(
                 plotlyOutput("distribution_plot"),
                 verbatimTextOutput("summary_text"),
                 plotlyOutput("density"),
                 plotlyOutput("confidencePlot")
               )
             ))
    #### end ####
    ,
    # Tab 2
    tabPanel("Tab 2",
             sidebarLayout(
               sidebarPanel(
                 # Inhalt der Seitenleiste für Tab 2
               ),
               mainPanel(
                 # Hauptinhalt für Tab 2
               )
             )),
    # Tab 3
    tabPanel("Tab 3",
             sidebarLayout(
               sidebarPanel(
                 # Inhalt der Seitenleiste für Tab 3
               ),
               mainPanel(
                 # Hauptinhalt für Tab 3
               )
             ))
  ))
