options(stringsAsFactors = FALSE, scipen = 999)

library(data.table)
library(lubridate)
library(readxl)

project_dir <- normalizePath(".", winslash = "/", mustWork = TRUE)

dir_raw_aurum <- 'C:/Users/bo297/OneDrive - University of Exeter/CPRD - General/Sample Data/Raw/Aurum'
dir_raw_gold  <- 'C:/Users/bo297/OneDrive - University of Exeter/CPRD - General/Sample Data/Raw/Gold'

file_cohort_aurum <- file.path(dir_raw_aurum, "Patientlist_Aurum_03032025.txt")
file_cohort_gold  <- file.path(dir_raw_gold, "Patientlist_Gold_03032025.txt")

dir_codelists_aurum <- paste0(project_dir,  "/codelists/Aurum")
dir_codelists_gold <- paste0(project_dir,  "/codelists/Gold")

minimum_age <- 40
maximum_age <- 110

dir_codelists <- file.path(project_dir, "codelists")
dir_derived   <- file.path(project_dir, "data", "derived")
dir_models    <- file.path(project_dir, "outputs", "models")
dir_tables    <- file.path(project_dir, "outputs", "tables")
dir_figures   <- file.path(project_dir, "outputs", "figures")

invisible(lapply(c(dir_derived, dir_models, dir_tables, dir_figures),
  dir.create,  recursive = TRUE,  showWarnings = FALSE))

id_var    <- "patid"
index_var <- "Indexdate"

study_start <- as.Date("2006-01-01")
study_end   <- as.Date("2023-12-31")

prediction_years <- c(0.25, 0.5, 1, 2, 3, 5)
prediction_days  <- round(prediction_years * 365.25)

baseline_days   <- 365
medication_days <- 90
fall_gap_days   <- 7

random_seed <- 2026
set.seed(random_seed)

