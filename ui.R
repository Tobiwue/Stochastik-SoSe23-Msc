# This is the user-interface definition of a Shiny web application.

library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)


# read miete03 (provided by the lecturer and is unchanged)
housing <- housing <- read.csv('./data/housing.csv', header = TRUE)

# Define UI for application that draws a histogram
fluidPage(
  tags$head(
    tags$style(
      HTML('
          .sidebar {
            position: fixed;
            width: 350px;
            overflow-y: auto;
          }
        ')
    )
  ),
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
               sidebarPanel( id= 'sidebar',class='sidebar',
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
  ))
