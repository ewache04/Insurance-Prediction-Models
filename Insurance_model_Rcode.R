# Health Insurance Dataset Analysis
# Author: Jeremiah Ochepo
# Date: February 16, 2024

# Load required packages
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}

library(tidyverse)
library(ggplot2)

# Define the file name
file_name <- "insurance_noisy_data.csv"

# Function to handle errors
handle_error <- function(task, e) {
  print(paste("Error occurred during", task, ":"))
  print(paste("Error message:", conditionMessage(e)))
}

# Load the dataset
tryCatch({
  insurance <- read.csv(file_name)
  cat("The '", file_name, "' has been loaded successfully.\n")
}, error = function(e) {
  cat("Error: ", conditionMessage(e), "\n")
  cat(paste("The '", file_name, "' file could not be loaded or found.\n", sep = ""))
  insurance <- NULL
})

# Data Cleaning and Transformation
tryCatch({
  # Convert smoker attribute to binary
  insurance$smoker_binary <- ifelse(insurance$smoker == "yes", 1, 0)

  # Replace missing or noisy data in expenses
  insurance$expenses[insurance$expenses <= 0] <- mean(insurance$expenses[insurance$expenses > 0], na.rm = TRUE)

  # Replace missing values in Statin Therapy column
  insurance$Statin.Therapy[is.na(insurance$Statin.Therapy)] <- "NO"

  print("Data cleaning completed successfully.")
}, error = function(e) {
  handle_error("data cleaning", e)
})

# Exploratory Data Analysis (EDA)
tryCatch({
  # Summary statistics
  summary_stats <- summary(insurance)
  print(summary_stats)

  # Plot 1: Distribution of Expenses
  ggplot(insurance, aes(x = expenses)) +
    geom_histogram(binwidth = 1000, fill = "blue", alpha = 0.7) +
    theme_minimal() +
    labs(title = "Distribution of Insurance Expenses", x = "Expenses", y = "Frequency")

  # Plot 2: Average Expenses by Smoker Status
  ggplot(insurance, aes(x = smoker_binary, y = expenses, fill = as.factor(smoker_binary))) +
    geom_bar(stat = "summary", fun = "mean", alpha = 0.7) +
    scale_fill_manual(values = c("green", "red"), labels = c("Non-Smoker", "Smoker")) +
    theme_minimal() +
    labs(title = "Average Expenses by Smoker Status", x = "Smoker Status (0 = Non-Smoker, 1 = Smoker)", y = "Average Expenses", fill = "Smoker")

  # Plot 3: BMI vs. Expenses by Smoking Status
  ggplot(insurance, aes(x = bmi, y = expenses, color = as.factor(smoker_binary))) +
    geom_point(alpha = 0.6) +
    theme_minimal() +
    labs(title = "BMI vs. Expenses by Smoking Status", x = "BMI", y = "Expenses", color = "Smoker")

  # Plot 4: LDL Cholesterol Levels and Statin Therapy
  ggplot(insurance, aes(x = LDL.cholesterol, fill = Statin.Therapy)) +
    geom_bar(position = "dodge", alpha = 0.7) +
    theme_minimal() +
    labs(title = "LDL Cholesterol Levels and Statin Therapy", x = "LDL Cholesterol Levels", y = "Count", fill = "Statin Therapy")

  # Plot 5: Expenses by Region
  ggplot(insurance, aes(x = region, y = expenses, fill = region)) +
    geom_boxplot(alpha = 0.7) +
    theme_minimal() +
    labs(title = "Expenses by Region", x = "Region", y = "Expenses")

}, error = function(e) {
  handle_error("exploratory data analysis", e)
})

# Save Cleaned Data
tryCatch({
  write.csv(insurance, file = "insurance_clean.csv", row.names = FALSE)
  print("Cleaned data saved successfully to 'insurance_clean_data.csv'.")
}, error = function(e) {
  handle_error("saving cleaned data", e)
})
