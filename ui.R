# This is the user-interface definition of a Shiny web application.

library(shiny)
library(ggplot2)
library(shinyWidgets)
library(grid)

<<<<<<< HEAD
# read miete03 (provided by the lecturer and is unchanged)
dataset <- dataset <- read.csv('./data/housing.csv', header = TRUE)
=======
housing <- read.csv("./data/housing.csv", header = TRUE)
chess <- read.csv("./data/chess.csv", header = TRUE)
>>>>>>> 8331008de768b8e82fe8934da4269cad74ebafa4

# Define UI for application that draws a histogram
fluidPage(
  titlePanel("ShinyApp Stochastik SoSe23 - HTW Berlin FB4 MSC"),
<<<<<<< HEAD
    tabsetPanel(
      # Tab 1
      tabPanel("Gaussian Distribution",
        sidebarLayout(
          sidebarPanel(
            sliderInput("threshold_range", "Scope", 
                  #min = 0, max = max(dataset$households), value = c(0, max(dataset$households)),step = 1)
                  min = 0, max = 2000, value = c(0, 2000),step = 1),
            numericInput("start_value", "Start Intervall", 0),
            numericInput("end_value", "End Intervall", 2000)
            ),
    mainPanel(
      plotOutput("gaussian_distribution_plot"),
      verbatimTextOutput("summary_text"),
      plotOutput("density")
         )
      )),
=======
  tabsetPanel(
    # Tab 1
    tabPanel("Gaussian Distribution",
             sidebarLayout(
               sidebarPanel(
                 sliderInput("threshold_range", "Scope", 
                             #min = 0, max = max(housing$households), value = c(0, max(housing$households)),step = 1)
                             min = 0, max = 500, value = c(0, 500),step = 1)
               ),
               mainPanel(
                 plotOutput("gaussian_distribution_plot"),
                 verbatimTextOutput("summary_text")
               )
             )),
>>>>>>> 8331008de768b8e82fe8934da4269cad74ebafa4
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
