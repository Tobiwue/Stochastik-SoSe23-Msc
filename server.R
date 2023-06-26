# This is the server logic of a Shiny web application.

library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)

# read california housing data
housing <- read.csv('./data/housing.csv', header = TRUE)

#### globalls ####
#pos <- position_dodge2(.2)
#### end ####

# use to plot multy plots in one picture


# Define server logic
function(input, output, session) {
  
  
  #### interval as reactive function ####
  # calc interval as reactive function
  range_interval <- reactive({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(housing, housing$households >= range_start & housing$households <= range_end)
    quantiles <- quantile(filtered_data$households, probs = c(.25, .5, .75))
    list(filtered_data = filtered_data, quantiles = quantiles)
  })
  #### end ####
  
  #### distribution as reactive function ####
  # calc distribution as reactive function
  calculate_normal <- reactive({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(housing, housing$households >= range_start & housing$households <= range_end)
    mean_value <- mean(filtered_data$households)
    sd_value <- sd(filtered_data$households)
    x <- seq(range_start, range_end, length.out = 100)
    y <- dnorm(x, mean = mean_value, sd = sd_value)
    data.frame(x = x, y = y)
  })
  #### end ####
  
  #### metadata textbox ####
  # metadata and summary in textbox
  output$summary_text <- renderText({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(housing, housing$households >= range_start & housing$households <= range_end)
    mean_value <- mean(filtered_data$households)
    sd_value <- sd(filtered_data$households)
    quantiles <- range_interval()$quantiles
    
    paste(
      " Range: [", range_start, "-", range_end, "]\n",
      paste("Mean:", round(mean_value, 2)),
      paste("SD:", round(sd_value, 2)," "),
      "\n Quantiles: \n",
      paste("Q1:", quantiles[1]," "),
      paste("Median:", quantiles[2]," "),
      paste("Q3:", quantiles[3])
    )
  })
  #### end ####
  
  #### distribution plot ####  
  # draw distribution zoomable plot
  output$distribution_plot <- renderPlotly({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(housing, housing$households >= range_start & housing$households <= range_end)
    mean_value <- mean(filtered_data$households)
    sd_value <- sd(filtered_data$households)
    quantiles <- range_interval()$quantiles
    
    mean_sd_plot<-ggplot() +
      geom_bar(data = filtered_data, aes(x = households), fill = "blue", color = "blue") +
      geom_vline(xintercept = range_start, linetype = "dotted", color = "brown", size = 1) +
      geom_vline(xintercept = range_end, linetype = "dotted", color = "brown", size = 1) +
      geom_vline(xintercept = quantiles[1:3], linetype = "dashed", color = "yellow", size = 1.5) +
      geom_text(aes(x = quantiles[1:3], y = 0, label = c("Q1", "Median", "Q3")), color = "black") + 
      labs(x = "Values", y = "Frequency") +
      theme_minimal()
    ggplotly(mean_sd_plot)
  })
  #### end ####
  
  #### density plot ####   
  #draw distribution with adjustable intervals via slider input
  output$density <- renderPlotly({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(housing, housing$households <=2000 )
    density_data <- density(filtered_data$households)
    quantiles <- quantile(filtered_data$households, probs = c(0.25, 0.5, 0.75))
    
    density_plot <- ggplot() +
      geom_vline(xintercept = range_start, linetype = "dashed", color = "green", size = 1.5) +
      geom_vline(xintercept = range_end, linetype = "dashed", color = "green", size = 1.5) +
      geom_density(data = filtered_data, aes(x = households), fill = "lightblue", alpha = .5) +
      geom_vline(xintercept = quantiles[1:3], linetype = "dashed", color = "orange", size = 1) +
      geom_text(aes(x = quantiles[1:3], y = 0, label = c("Q1", "Median", "Q3")), color = "black") + 
      
      labs(x = "Values", y = "Density") +
      theme_minimal()
    ggplotly(density_plot)
  })
  #### end ####
  
  #### errorbar as reactive function ####
  error_bar_data <- reactiveValues(data = data.frame())
  calculate_error_bar <- reactive({
    data <- rnorm(input$samplesize)
    range_start <- 0
    range_end <- 2000
    filtered_data <- subset(housing, housing$households <= 2000)
    mean_value <- mean(filtered_data$households)
    sd_value <- sd(filtered_data$households)
    #error <- qnorm(1 - (1 - input$confidence) / 2) * sd(data) / sqrt(input$samplesize)
    error <- qt((1 - (input$confidence)/2),input$samplesize-1)*sd_value / sqrt(input$samplesize)
    error_upper <- mean_value + error * sd_value
    error_lower <- mean_value - error * sd_value
    lower_bound <- mean_value - error
    upper_bound <- mean_value + error
    data.frame(x=1,mean_value = mean_value, upper = error_upper, lower = error_lower, lower_bound = lower_bound, upper_bound = upper_bound)
  })
  #### end ####
  
  #### observer logic for confidencePlot ####
  # observer resetButton
  observeEvent(input$resetButton, {
    error_bar_data$data <- data.frame()
    output$confidencePlot <- renderPlotly(NULL)
  })
  
  # observer addButton
  observeEvent(input$addButton, {
    add_errorbar()
    output$confidencePlot <- renderPlotly({
      createPlot(error_bar_data$data)
    })
  })
  #### end ####
  
  #### add_errorbar with dodge function ####
  current_x <- 1
  add_errorbar <- function() {
    calculated_data <- calculate_error_bar()
    new_data <- data.frame(x = current_x,
                           mean_value = calculated_data$mean_value,
                           lower_bound = calculated_data$lower_bound,
                           upper_bound = calculated_data$upper_bound)
    error_bar_data$data <- rbind(error_bar_data$data, new_data)
    current_x <<- current_x + 1
  }
  #### end ####
  
  #### confidence plot ####
  createPlot <- function(data) {
    confidencePlot <- ggplot(data, aes(x = x, y = mean_value)) +
      geom_point(size = 3, aes(text = paste0("Mean: ", round(mean_value, 3), "<br>",
                                             "Error: ", round(upper_bound - mean_value, 3), "<br>",
                                             "Lower Bound: ", round(lower_bound, 3), "<br>",
                                             "Upper Bound: ", round(upper_bound, 3)))) +
      geom_errorbar(aes(y = mean_value, ymin = lower_bound, ymax = upper_bound),
                    width = 0.4) +
      #coord_flip() +
      labs(x = "", y = "") +
      theme_minimal()
    ggplotly(confidencePlot)
  }
  #### end ####
  
  
  
}

