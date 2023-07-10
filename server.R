# This is the server logic of a Shiny web application.

library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)

# read california housing data
housing <- read.csv('./data/housing.csv', header = TRUE)

#### globals ####
#### end ####

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
  #calculate_normal <- reactive({
  #range_start <- input$threshold_range[1]
  #range_end <- input$threshold_range[2]
  #filtered_data <- subset(housing, housing$households >= range_start & housing$households <= range_end)
  #mean_value <- mean(filtered_data$households)
  #sd_value <- sd(filtered_data$households)
  #x <- seq(range_start, range_end, length.out = 100)
  # y <- dnorm(x, mean = mean_value, sd = sd_value)
  #data.frame(x = x, y = y)
  # })
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
      geom_bar(data = filtered_data, aes(x = households), fill = "#C8DAEA", color = "#C8DAEA") +
      geom_vline(xintercept = range_start, linetype = "solid", color = "#192A51", size = 0.5) +
      geom_vline(xintercept = range_end, linetype = "solid", color = "#192A51", size = 0.5) +
      geom_vline(xintercept = mean_value, linetype = "solid", color = "#428bca", size = 0.5) +
      geom_vline(xintercept = quantiles[1:3], linetype = "dashed", color = "#428bca", size = 0.5) +
      geom_text(aes(x = quantiles[1:3], y = 0, label = c("Q1", "Q2", "Q3")), color = "black") + 
      geom_text(aes(x = mean_value, y = 0, label = "Mean"), color = "black", y= 5) +
      labs(x = "Values", y = "Frequency") +
      theme_minimal()
    ggplotly(mean_sd_plot)
  })
  #### end ####
  
  #### density plot ####   
  output$density <- renderPlotly({
    range_start <- input$threshold_range[1]
    range_end <- input$threshold_range[2]
    filtered_data <- subset(housing, housing$households <=2000 )
    quantiles <- quantile(filtered_data$households, probs = c(.25, .5, .75))
    mean_value <- round(mean(filtered_data$households),0)
    
    density_plot <- ggplot() +
      geom_vline(xintercept = range_start, linetype = "solid", color = "#192A51", size = 0.5) +
      geom_vline(xintercept = range_end, linetype = "solid", color = "#192A51", size = 0.5) +
      geom_vline(xintercept = mean_value, linetype = "solid", color = "#428bca", size = 0.5) +
      geom_density(data = filtered_data, aes(x = households), fill = "#C8DAEA", alpha = .5) +
      geom_vline(xintercept = quantiles[1:3], linetype = "dashed", color = "#428bca", size = 0.5) +
      geom_text(aes(x = quantiles[1:3], y = 0, label = c("Q1", "Q2", "Q3")), color = "black") +
      geom_text(aes(x = mean_value, y = 0, label = "Mean"), color = "black", y= 0.00025) +
      labs(x = "Values", y = "Density") +
      theme_minimal()
    ggplotly(density_plot)
  })
  #### end ####
  
  #### get sample for interval as reactive function ####
  sample_data <- reactive({
    filtered_data <- subset(housing, housing$households <=2000 )
    samples <- sample(filtered_data$households, size = input$samplesize)
  })
  #### end ####
  
  #### errorbar as reactive function ####
  error_bar_data <- reactiveValues(data = data.frame())
  calculate_error_bar <- reactive({
    sample_mean <- mean(sample_data())
    sample_sd <- sd(sample_data())
    conf_int <- t.test(sample_data(), conf.level=input$confidence)$conf.int
    upper_bound <- conf_int[2]
    lower_bound <- conf_int[1]
    error <- (upper_bound - lower_bound) / 2
    
    data.frame(x='Sample', mean_value = sample_mean, lower_bound = lower_bound, upper_bound = upper_bound)
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
      geom_point(size = 3, aes(text = paste(" Mean: ", round(mean_value, 3), "<br>",
                                            "Error: ", round(upper_bound - mean_value, 3), "<br>",
                                            "Lower Bound: ", round(lower_bound, 3), "<br>",
                                            "Upper Bound: ", round(upper_bound, 3)))) +
      geom_errorbar(aes(y = mean_value, ymin = lower_bound, ymax = upper_bound),
                    width = 0.4) +
      #coord_flip() +
      labs(x = "", y = "") +
      theme_minimal()
    ggplotly(confidencePlot, tooltip = "text")
  }
  #### end ####
  
  #### qq plot ####
  output$qqplot <- renderPlotly({
    filtered_data <- lapply(housing, head, 2000)
    qqdata <- as.data.frame(filtered_data[[input$column]])
    
    #draw qqplot
    qqplot <- ggplot(qqdata, aes(sample = qqdata[, 1])) +geom_qq() +
      geom_qq_line() +
      labs(title =input$column,x = "Theoretical quantiles", y = "Empirical quantiles")
    ggplotly(qqplot)
  })
  #### end ####
  
  #### shapiro test ####
  output$shapirotest <- renderText({
    filtered_data <- lapply(housing, head, 2000)
    qqdata <- as.data.frame(filtered_data[[input$column]])
    
    sample_size <- input$qq_samplesize
    sample_data <- head(qqdata, min(sample_size, nrow(qqdata)))
    
    # Shapiro-Wilk-Test durchführen
    result <- shapiro.test(sample_data[, 1])
    
    # Ergebnis anzeigen
    paste(
      result$method, ":\n",
      sprintf("W-Value: %.4f\n", result$statistic),
      paste("P-Value:",result$p.value)
    )
    
  })
  
  #### end ####
  
  
  
  
  
  
  
  
  
  
  output$h1_grenze <- renderText({ input$h0_grenze })
  
  
  
  #### Dataset updated as reactive ####
  data_r <- reactive({
    f_data <- subset(housing, housing$households >= input$hypo_range[1] & housing$households <= input$hypo_range[2])
  })
  #### end ####
  
  
  #### T-Test as reactive ####
  t_test_r <- reactive({  
    data <- data_r()
    data <- data$households
    
    if (input$hypothesis_test == "Left-tailed") {type <- "less"}
    else if (input$hypothesis_test == "Right-tailed") {type <- "greater"}
    else {type <- "two.sided"}
    t_test <- t.test(data, mu = input$h0_grenze, alternative = type, conf.level = input$alpha)
  })
  #### end ####
  
  output$ttest <- renderText({ paste(t_test_r()) })
  
  
  #### Hyppothesentest plot ####
  output$hypothesentest_plot <- renderPlotly({
    data <- data_r()
    data <- data$households
    
    t_test <- t_test_r()
    
    hypo_plot <- ggplot() +
      geom_bar(data = data_r(), aes(x = households), fill = "#C8DAEA", color = "#C8DAEA") +
      geom_vline(xintercept = input$hypo_range[1], linetype = "solid", color = "#192A51", size = 0.5) +
      geom_vline(xintercept = input$hypo_range[2], linetype = "solid", color = "#192A51", size = 0.5) +
      geom_vline(xintercept = input$h0_grenze, linetype = "solid", color = "#428bca", size = 0.5) +
      geom_vline(xintercept = t_test$conf.int, linetype = "dashed", color = "#428bca", size = 0.5) +
      geom_text(aes(x = t_test$conf.int, y = 0, label = c("a/2", "1-(a/2)")), color = "black") + 
      geom_text(aes(x = input$h0_grenze, y = 0, label = "H0 Grenze"), color = "black", y= 5) +
      labs(x = "Values", y = "Frequency") +
      theme_minimal()
    ggplotly(hypo_plot)
  })
  #### end ####
}
