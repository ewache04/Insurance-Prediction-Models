# Assignment 3: Health Insurance Dataset Analysis
# Author: Jeremiah Ochepo
# Date: February 16, 2024

# Check if the tidyverse package is already installed
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  # If not installed, install it
  install.packages("tidyverse")
}

# Load the tidyverse package
library(tidyverse)

# Define the file name
file_name <- "insurance_noisy.csv"

# Function to handle errors
handle_error <- function(task, e) {
  print(paste("Error occurred during", task, ":"))
  print(paste("Error message:", conditionMessage(e)))
}

# Attempt to load the dataset into R
tryCatch({
  insurance <- read.csv(file_name)
  
  # Print success message
  cat("The '", file_name, "' has been loaded successfully.\n")
}, error = function(e) {
  # Handle the error
  cat("Error: ", conditionMessage(e), "\n")
  cat(paste("The '", file_name, "' file could not be loaded or found.\n", sep = ""))
  # Optionally, you can assign insurance as NULL or any other value to indicate failure
  insurance <- NULL
})


# Explore the Dataset

# View the first few rows of the dataset
tryCatch({
  head(insurance)
}, error = function(e) {
  handle_error("viewing the first few rows of the dataset", e)
})

# Calculate summary statistics of the dataset
tryCatch({
  insurance_summary <- summary(insurance)
}, error = function(e) {
  handle_error("calculating summary statistics of the dataset", e)
})

# Display structure of the dataset
tryCatch({
  insurance_structure <- str(insurance)
}, error = function(e) {
  handle_error("displaying the structure of the dataset", e)
})

# Display column names
tryCatch({
  insurance_colnames <- colnames(insurance)
}, error = function(e) {
  handle_error("displaying column names of the dataset", e)
})

# Display a concise summary of the dataset
tryCatch({
  library(dplyr)
  insurance_glimpse <- glimpse(insurance)
}, error = function(e) {
  handle_error("displaying a concise summary of the dataset", e)
})

# View the entire dataset in RStudio's data viewer
tryCatch({
  insurance_data_viewer <- View(insurance)
}, error = function(e) {
  handle_error("viewing the entire dataset in RStudio's data viewer", e)
})

# Task 1: Explore the dataset to describe attributes
tryCatch({
  # Check if the dataset is loaded
  if (!exists("insurance")) {
    stop("Dataset not found. Please load the dataset before running Task 1.")
  }
  
  # Define attribute types as strings for better readability
  attribute_types <- sapply(insurance, function(x) as.character(class(x)))
  
  # Create attribute description dataframe
  attribute_names <- c("age", "sex", "bmi", "children", "smoker", "LDL.cholesterol", "Statin.Therapy", "region", "expenses", "smoker_binary", "Statin.Therapy_binary")
  attribute_descriptions <- c(
    "Patient's age",
    "Patient's gender",
    "Body Mass Index (BMI)",
    "Number of children/dependents covered by insurance",
    "Whether the patient smokes or not",
    "LDL Cholesterol level",
    "Whether the patient is under Statin Therapy or not",
    "Geographic region of the patient",
    "Expenses incurred by the patient"
  )
  
  attribute_description <- data.frame(
    "Attribute" = attribute_names,
    "Description" = attribute_descriptions,
    "Attribute_Type" = attribute_types
  )
  
  # Print attribute description
  print(attribute_description)
}, error = function(e) {
  handle_error("exploring the dataset to describe attributes", e)
})


# Task 2: Explore the dataset to answer the questions
tryCatch({
  # 1. Different values of Cholesterol levels and their attribute type
  cholesterol_levels <- unique(insurance$LDL.cholesterol)
  cholesterol_attribute_type <- as.character(class(insurance$LDL.cholesterol))
  
  # 2. Candidates for Statin Therapy
  candidates_for_statin <- subset(insurance, LDL.cholesterol %in% c("Med", "High") & Statin.Therapy == "NO")
  
  # 3. Replace missing values in Statin Therapy column if represented as "NA"
  missing_statin <- sum(is.na(insurance$Statin.Therapy))
  if (missing_statin > 0) {
    insurance$Statin.Therapy[is.na(insurance$Statin.Therapy)] <- "NO"  # Replace missing values with NO
  }
  
  # 4. Attributes convertible to binary values
  insurance$smoker_binary <- ifelse(insurance$smoker == "yes", 1, 0)
  insurance$Statin.Therapy_binary <- ifelse(insurance$Statin.Therapy == "YES", 1, 0)
  
  # Summary of the transformations
  summary_report <- data.frame(
    "Cholesterol_Levels" = rep(cholesterol_levels, 2), # Repeat levels to match the length of other vectors
    "Cholesterol_Attribute_Type" = rep(cholesterol_attribute_type, 2), # Repeat types to match the length of other vectors
    "Candidates_for_Statin_Therapy" = rep(nrow(candidates_for_statin), length(cholesterol_levels)), # Repeat the number of candidates for each cholesterol level
    "Missing_Statin_Therapy_Values" = missing_statin,
    "Attributes_Converted_to_Binary" = c("smoker", "Statin.Therapy")
  )
  
  # Print summary report
  print(summary_report)
}, error = function(e) {
  handle_error("exploring the dataset to answer the questions", e)
})

# Task 3: Data Cleaning
tryCatch({
  # Change smoker attribute values to 0 and 1
  insurance$smoker <- ifelse(insurance$smoker == "yes", 0, 1)
  
  # Clean up noisy data in 'expenses'
  insurance$expenses[insurance$expenses == 0] <- mean(insurance$expenses, na.rm = TRUE)
  insurance$expenses[insurance$expenses == -1] <- median(insurance$expenses, na.rm = TRUE)
  print("Noisy data cleaning process executed successfully.")
  
}, error = function(e) {
  handle_error("data cleaning", e)
})

# Save cleaned-up data
tryCatch({
  write.csv(insurance, file = "insurance_clean.csv", row.names = FALSE)
  print("Cleaned-up data saved successfully.")
}, error = function(e) {
  handle_error("saving cleaned-up data", e)
})

