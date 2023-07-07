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
    tabPanel("Welcome Page",
             mainPanel(
               h2("Welcome to our Shiny App!"),
               HTML("<h3>This Shiny App includes different topics:</h3>
               <ul>
               <li>An interactive exploration of the dataset</li>
               <li>A static analysis of the dataset</li>
               <li>Calculation of various values by user input</li>
               <li>Calculation of confidence intervals using two input sliders</li>
               <li>Calculation of a Q-Q-Plot for columns selected by the user</li>
               <li>A Shapiro–Wilk test for columns selected by the user</li>
               
                    </ul>",
                    "<h4>The nature of our app is data exploration, so more features may be added in the future.</h4>"
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
               sidebarPanel(id= 'sidebar',class='sidebar',
                             selectInput("Testseite", "Testseite:",
                                         c("Linksseitiger Test" = "lt",
                                           "Rechtsseitiger Test" = "rt",
                                           "Zweiseitiger Test" = "zt")
                                         ),
                            fluidRow(
                              div(style="display: inline-block", h5("H\u2080: \U0078\U0304 \u2264 ")),
                              div(style="display: inline-block", textInput("h1", "", width = "50px"))
                            ),
                            
                            fluidRow(
                              div(style="display: inline-block", h5("H\u2081: \U0078\U0304 \u003e ")),
                              div(style="display: inline-block", textInput("h1", "", width = "50px"))
                            )
                             ),
               mainPanel(
                 plotlyOutput("hypothesentest_plot"),
                 verbatimTextOutput("hypothesentest_text")
               )
             )
            ),
    #### end ####
    
    #### Tab 4 - Q-Q-Plot ####
    tabPanel("Q-Q-Plot",
             sidebarLayout(
               sidebarPanel(
                selectInput("column", label = "Choose Column", choices = colnames(housing)),
                sliderInput("qq_samplesize", label = "Sample Size for Shapiro-Wilk normality test", 3, 2000, 3)
                            
               ),
               mainPanel(
                 plotlyOutput("qqplot"),
                 verbatimTextOutput("shapirotest")
               )
             )
    ),
    #### end ####
    #### Tab 5 Information ####
    tabPanel("Information",
               mainPanel('this'
               )
             )
    )
    #### end ####
  )
#### end ####
