# This is the server logic of a Shiny web application.

library(shiny)
library(ggplot2)
library(shinyWidgets)
library(grid)

# read miete03 (provided by the lecturer and is unchanged)
dataset <- read.csv('./data/housing.csv', header = TRUE)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  # calc interval as reactive function
  range_interval <- reactive({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(dataset, dataset$households >= range_start & dataset$households <= range_end)
    quantiles <- quantile(filtered_data$households, probs = c(0.25, 0.5, 0.75))
    list(filtered_data = filtered_data, quantiles = quantiles)
  })
  
  # calc for gaussian distribution
  calculate_normal <- reactive({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(dataset, dataset$households >= range_start & dataset$households <= range_end)
    mean_value <- mean(filtered_data$households)
    sd_value <- sd(filtered_data$households)
    x <- seq(range_start, range_end, length.out = 100)
    y <- dnorm(x, mean = mean_value, sd = sd_value)
    data.frame(x = x, y = y)
  })
  
  # metadata and summary
  output$summary_text <- renderText({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(dataset, dataset$households >= range_start & dataset$households <= range_end)
    mean_value <- mean(filtered_data$households)
    sd_value <- sd(filtered_data$households)
    quantiles <- range_interval()$quantiles
    
    paste(
      " Range: [", range_start, "-", range_end, "]\n",
      "Mean: ", round(mean_value, 2), "\n",
      "SD:   ", round(sd_value, 2),"\n",
      "Quantiles: \n",
      "Q1: ", quantiles[1], "\n",
      "Median: ", quantiles[2], "\n",
      "Q3: ", quantiles[3]
    )
  })
  
  # draw gaussian distribution zoomable plot
   output$gaussian_distribution_plot <- renderPlot({
      range_start <- input$threshold_range[1]
      range_end <- input$threshold_range[2]
      filtered_data <- subset(dataset, dataset$households >= range_start & dataset$households <= range_end)
      mean_value <- mean(filtered_data$households)
      sd_value <- sd(filtered_data$households)
      quantiles <- range_interval()$quantiles
      
      mean_sd_plot<-ggplot() +
      geom_bar(data = filtered_data, aes(x = households), fill = "blue", color = "blue", binwidth = 0.1) +
      geom_line(data = calculate_normal(), aes(x = x, y = y), color = "red", size = 1) +
      geom_vline(xintercept = range_start, linetype = "dotted", color = "brown", size = 1) +
      geom_vline(xintercept = range_end, linetype = "dotted", color = "brown", size = 1) +
        geom_vline(xintercept = quantiles[1], linetype = "dashed", color = "yellow", size = 1.5) +
        geom_vline(xintercept = quantiles[2], linetype = "dashed", color = "yellow", size = 1.5) +
        geom_vline(xintercept = quantiles[3], linetype = "dashed", color = "yellow", size = 1.5) +
        geom_text(aes(x = quantiles[1], y = 0, label = "Q1", vjust = 1.5), color = "black") +
        geom_text(aes(x = quantiles[2], y = 0, label = "Median", vjust = 1.5), color = "black") +
        geom_text(aes(x = quantiles[3], y = 0, label = "Q3", vjust = 1.5), color = "black") +
        
      labs(x = "Values", y = "Frequenzy") +
      theme_minimal()
      print(mean_sd_plot)
      
  })
   #draw distribution with adjustable intervals via slider input
   output$density <- renderPlot({
      range_start <- input$threshold_range[1]
      range_end <- input$threshold_range[2]
      filtered_data <- subset(dataset, dataset$households <=2000 )
      density_data <- density(filtered_data$households)
      quantiles <- quantile(filtered_data$households, probs = c(0.25, 0.5, 0.75))
     
   density_plot <- ggplot() +
      geom_vline(xintercept = range_start, linetype = "dashed", color = "green", size = 1.5) +
      geom_vline(xintercept = range_end, linetype = "dashed", color = "green", size = 1.5) +
      geom_density(data = filtered_data, aes(x = households, y = after_stat(density)), fill = "lightblue", alpha = 0.5) +
      geom_vline(xintercept = quantiles[1], linetype = "dashed", color = "orange", size = 1) +
      geom_vline(xintercept = quantiles[2], linetype = "dashed", color = "orange", size = 1) +
      geom_vline(xintercept = quantiles[3], linetype = "dashed", color = "orange", size = 1) +
      geom_text(aes(x = quantiles[1], y = 0, label = "Q1", vjust = 1.5), color = "black") +
      geom_text(aes(x = quantiles[2], y = 0, label = "Median", vjust = 1.5), color = "black") +
      geom_text(aes(x = quantiles[3], y = 0, label = "Q3", vjust = 1.5), color = "black") +
      labs(x = "Values", y = "Density") +
      theme_minimal()
  
      print(density_plot)
   })
}
