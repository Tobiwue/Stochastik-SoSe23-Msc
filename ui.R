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
  titlePanel("ShinyApp Stochastik WI MSc SoSe23"),span(img(src = "HTW_Logo.jpg", height = 35)),
  tabsetPanel(
    
    #### Tab 1 - Welcome Page ####
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
    
    #### Tab 3 - Hypothesis testing ####
    tabPanel("Hypothesis testing",
             sidebarLayout(
               sidebarPanel(id = 'sidebar', class ='sidebar',
                            sliderInput("hypo_range", "Scope", 
                                        #min = 0, max = max(housing$households), value = c(0, max(housing$households)),step = 1)
                                        min = 0, max = 2000, value = c(0, 2000),step = 1),
                            
                            selectInput("Hypothesis test", "Testtype:",
                                        c("Left-tailed" = "lt",
                                          "Right-tailed" = "rt",
                                          "Two-tailed" = "zt")
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
             )),
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
    
    #### Tab 5 - Information ####
    tabPanel("Information",
             mainPanel(
               HTML("<h3>Group Members</h3>
                  <ul>
                    <li>Alice Kitchkin</li>
                    <li>Jan Lüken</li>
                    <li>Tobia Wübben</li>
                  </ul>",
                    "<h3>Sources</h3>",
                    "<ul>
                    <li><a>https://www.kaggle.com/datasets/darshanprabhu09/california-housing-dataset</a></li>
                    <li><a>https://de.wikibooks.org/wiki/GNU_R:_shapiro.test</a></li>
                    <li><a>https://rpubs.com/stammler/851041</a></li>
                    <li><a>https://plotly.com/ggplot2/getting-started/</a></li>
                    <li><a>https://www.r-bloggers.com/2021/06/qq-plots-in-r-quantile-quantile-plots-quick-start-guide/</a></li>
                    <li><a>https://de.wikipedia.org/wiki/Shapiro-Wilk-Test</a></li>
                    <li><a>https://shiny.posit.co/r/articles/build/html-tags/</a></li>
                  </ul>"
               )#<li><a></a></li>
             )
    )
    #### end ####
  )
  
)
#### end ####
