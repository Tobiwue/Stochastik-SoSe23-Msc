# This is the user-interface definition of a Shiny web application.

library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)


# read miete03 (provided by the lecturer and is unchanged)
housing <- read.csv('./data/housing.csv', header = TRUE)

#### UI ####
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
  titlePanel(title = span(img(src = "HTW_Logo.jpg", height = 35), "ShinyApp Stochastik SoSe23 - HTW Berlin FB4 MSC")),
  tabsetPanel(
    
    #### Info Tab ####
    tabPanel("Information",
             mainPanel(
               h2("Herzlich willkommen zu unserer Shiny App!"),
               HTML("<h3>Diese Shiny App beinhaltet verschiedene Themen:</h3>
               <ul>
               <li>Eine interaktive Erforschung des Datensatzes</li>
               <li>Eine statische Analyse der Daten</li>
               <li>Berechnung diverser Werte durch Nutzereingabe</li>
               <li>Berechnung von Konfidenzintervallen anhand zweier Inputslider</li>
                    </ul>",
                    "<h4>Die Natur unserer App ist die Erkundung der Daten, daher können in
                    Zukunft noch weitere Funktionen hinzugefügt werden.</h4>"
                    )
               )
             ),
    #### end ####
    #### Tab 2 - Confidence Interval ####
    tabPanel("Exploration",
             sidebarLayout(
               sidebarPanel(id= 'sidebar',class='sidebar',
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
             )
    ),
    #### end ####
    #### Tab 3 - Hypothesentest ####
    tabPanel("Hypothesentest",
             sidebarLayout(
               sidebarPanel(id = 'sidebar', class ='sidebar',
                            sliderInput("hypo_range", "Scope", 
                                        #min = 0, max = max(housing$households), value = c(0, max(housing$households)),step = 1)
                                        min = 0, max = 2000, value = c(0, 2000),step = 1),
                            
                            selectInput("Testtype", "Testtype:",
                                        c("Leftsided test" = "lt",
                                          "Rightsided test" = "rt",
                                          "Twosided test" = "zt")
                                        ),
                            fluidRow(
                              div(style="display: inline-block", h5("H\u2080: \U0078\U0304 \u2264 ")),
                              div(style="display: inline-block", numericInput("h0_grenze", "", value=300, min = 0, width = "80px"))
                            ),
                            fluidRow(
                              div(style="display: inline-block", h5("H\u2081: \U0078\U0304 \u003e ")),
                              div(style="display: inline-block", textOutput("h1_grenze"),)
                            ),
                            sliderInput("alpha", "Confidence Level", .9, .99, .9, step = 0.01)
                            ),
               mainPanel(
                 plotlyOutput("hypothesentest_plot"),
                 verbatimTextOutput("ttest")
               )
             ))
    #### end ####
  ))
#### end ####
