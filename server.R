# This is the server logic of a Shiny web application.

library(shiny)
library(ggplot2)
library(shinyWidgets)
library(grid)

housing <- read.csv("./housing.csv", header = TRUE)
chess <- read.csv("./chess.csv", header = TRUE)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  # calc for gaussian distribution
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
  
  # meta data
  output$summary_text <- renderText({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    
    filtered_data <- subset(housing, housing$households >= range_start & housing$households <= range_end)
    mean_value <- mean(filtered_data$households)
    sd_value <- sd(filtered_data$households)
    
    paste(
      "Range: [", range_start, "-", range_end, "]\n",
      "Mean: ", round(mean_value, 2), "\n",
      "SD:   ", round(sd_value, 2)
    )
  })
  
  # draw plot
  output$gaussian_distribution_plot <- renderPlot({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(housing, housing$households >= range_start & housing$households <= range_end)
    mean_value <- mean(filtered_data$households)
    sd_value <- sd(filtered_data$households)
    
    mean_sd_plot<-ggplot() +
      geom_histogram(data = filtered_data, aes(x = households), binwidth = 0.1, fill = "blue", color = "black") +
      geom_line(data = calculate_normal(), aes(x = x, y = y), color = "red", size = 1) +
      geom_vline(xintercept = range_start, linetype = "dashed", color = "green", size = 1) +
      geom_vline(xintercept = range_end, linetype = "dashed", color = "green", size = 1) +
      labs(x = "Values", y = "Frequenzy") +
      theme_minimal()
    
    print(mean_sd_plot)
    print(mean_sd_plot)
  })
}
