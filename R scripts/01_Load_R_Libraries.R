############################################################
# Script: 01_load_libraries.R
# Project: Fall Prediction in Heart Failure Cohort using Machine Learning
#
# Purpose:
# Load all R packages required for cohort construction, feature
# engineering, model development, evaluation, and dashboard outputs.
############################################################

# Data handling
library(data.table)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(lubridate)
library(readxl)
library(openxlsx)
library(writexl)
library(here)

# Missing data
library(mice)

# Modelling
library(caret)
library(glmnet)
library(ranger)
library(ada)
library(xgboost)
library(lightgbm)

# Model evaluation
library(pROC)

# Survival and competing risks
library(survival)
library(survminer)
library(cmprsk)

# Visualisation
library(ggplot2)
library(patchwork)
library(plotly)

# Dashboard
library(shiny)
