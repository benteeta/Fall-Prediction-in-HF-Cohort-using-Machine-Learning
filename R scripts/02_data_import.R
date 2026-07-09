############################################################
# Script: 02_data_import_template.R
# Project: Fall Prediction in Heart Failure Cohort using Machine Learning
# Purpose: Provide a template for importing source datasets required for the heart failure falls prediction pipeline.
# Notes: This script uses placeholder file names and assumes files are stored in data/raw/. Do not commit restricted patient-level data.
############################################################

source(here::here("R", "01_load_libraries.R"))
source(here::here("R", "helper_functions.R"))


#-----------------------------------------------------------
# Define input file paths
#-----------------------------------------------------------

patient_file <- here::here("data", "raw", "Patientdata.xlsx")
index_file <- here::here("data", "raw", "Indexdates.xlsx")
bmi_file <- here::here("data", "raw", "bodymassindex.xlsx")
falls_file <- here::here("data", "raw", "CleanFalls.xlsx")
admissions_file <- here::here("data", "raw", "Hospital_admissions.xlsx")
prescriptions_file <- here::here("data", "raw", "Prescriptions.xlsx")
frailty_file <- here::here("data", "raw", "Frailty.xlsx")


#-----------------------------------------------------------
# Import data
#-----------------------------------------------------------

patient_data <- read_excel_sheets(patient_file)
index_dates <- read_excel_sheets(index_file)
bmi_data <- read_excel_sheets(bmi_file)
falls_data <- read_excel_sheets(falls_file)
admissions_data <- read_excel_sheets(admissions_file)
prescriptions_data <- read_excel_sheets(prescriptions_file)
frailty_data <- read_excel_sheets(frailty_file)


#-----------------------------------------------------------
# Save imported objects for later scripts
#-----------------------------------------------------------

saveRDS(patient_data, here::here("data", "processed", "patient_data_raw.rds"))
saveRDS(index_dates, here::here("data", "processed", "index_dates_raw.rds"))
saveRDS(bmi_data, here::here("data", "processed", "bmi_data_raw.rds"))
saveRDS(falls_data, here::here("data", "processed", "falls_data_raw.rds"))
saveRDS(admissions_data, here::here("data", "processed", "admissions_data_raw.rds"))
saveRDS(prescriptions_data, here::here("data", "processed", "prescriptions_data_raw.rds"))
saveRDS(frailty_data, here::here("data", "processed", "frailty_data_raw.rds"))
