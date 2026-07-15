############################################################
# Script: 04_feature_engineering.R
# Project: Fall Prediction in Heart Failure Cohort using
#          Machine Learning
#
# Purpose:
# Derive BMI, fall outcomes, previous fall history, and
# follow-up variables for the heart failure cohort.
#
# Inputs:
# - data/processed/hf_cohort_base.rds
# - data/processed/index_dates_raw.rds
# - data/processed/bmi_data_raw.rds
# - data/processed/falls_data_raw.rds
# - data/processed/admissions_data_raw.rds
#
# Outputs:
# - data/processed/bmi_features.rds
# - data/processed/fall_features.rds
############################################################

source(here::here("R", "01_load_libraries.R"))
source(here::here("R", "helper_functions.R"))


#-----------------------------------------------------------
# Analysis parameters
#-----------------------------------------------------------

study_end_date <- as.Date("2023-12-31")

#-----------------------------------------------------------
# Load source data
#-----------------------------------------------------------

hf_cohort_base <- readRDS(here::here("data", "processed", "hf_cohort_base.rds"))
index_dates <- readRDS( here::here("data", "processed", "index_dates_raw.rds"))
bmi_raw <- readRDS( here::here("data", "processed", "bmi_data_raw.rds"))
falls_raw <- readRDS(here::here("data", "processed", "falls_data_raw.rds"))
admissions_raw <- readRDS(here::here("data", "processed", "admissions_data_raw.rds"))

#-----------------------------------------------------------
# Prepare heart failure index dates
#-----------------------------------------------------------
hf_index <-  index_dates %>%  transmute(patid,   patID,    Indexdate_HFailure = lubridate::ymd(Indexdate_HFailure)) %>%
  filter(!is.na(Indexdate_HFailure)) %>% distinct(patid, patID, .keep_all = TRUE)

#-----------------------------------------------------------
# Derive BMI features
#-----------------------------------------------------------
bmi_annual <-  bmi_raw %>%  transmute(patid, patID, visitdate = lubridate::ymd(visitdate), Indexdate_HFailure = lubridate::ymd(Indexdate_HFailure),  bmi = suppressWarnings(as.numeric(bmi))) %>%
  filter(!is.na(patid), !is.na(patID), !is.na(visitdate), !is.na(Indexdate_HFailure)
  ) %>%
  mutate(
    year = lubridate::year(visitdate),
    years_withHFdiag =
      year - lubridate::year(Indexdate_HFailure)
  ) %>%
  filter(years_withHFdiag >= 0) %>%
  group_by(
    patid,
    patID,
    year,
    years_withHFdiag
  ) %>%
  summarise(
    bmi = mean(bmi, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    bmi = ifelse(is.nan(bmi), NA_real_, bmi),
    bmi = round(bmi, 2)
  )


# Select the latest available BMI measurement after HF diagnosis.
#
# This preserves the logic of the original analysis. However, using
# measurements recorded after cohort entry may introduce information
# leakage if the model is intended to predict risk at HF diagnosis.
# The index-date measurement window should therefore be defined
# explicitly before the final model is reported.

bmi_features <-
  bmi_annual %>%
  group_by(patid) %>%
  slice_max(
    order_by = years_withHFdiag,
    n = 1,
    with_ties = FALSE
  ) %>%
  ungroup() %>%
  select(
    patid,
    patID,
    bmi,
    bmi_measurement_year = year,
    bmi_years_after_hf = years_withHFdiag
  )


#-----------------------------------------------------------
# Derive primary-care fall records
#-----------------------------------------------------------

primary_care_falls_all <-
  falls_raw %>%
  semi_join(
    hf_cohort_base %>% distinct(patid),
    by = "patid"
  ) %>%
  transmute(
    patid,
    Eventdate = lubridate::ymd(Eventdate),
    term,
    recorded_death_date = lubridate::ymd(DeathDate)
  ) %>%
  left_join(
    hf_index %>%
      select(patid, Indexdate_HFailure),
    by = "patid"
  ) %>%
  filter(
    !is.na(Eventdate),
    !is.na(Indexdate_HFailure)
  ) %>%
  mutate(
    time_to_fall_years =
      as.numeric(
        difftime(
          Eventdate,
          Indexdate_HFailure,
          units = "days"
        )
      ) / 365.25
  )


primary_care_fall_history <-
  primary_care_falls_all %>%
  group_by(patid) %>%
  summarise(
    primary_care_fall_history =
      ifelse(any(time_to_fall_years < 0), "Yes", "No"),
    .groups = "drop"
  )


primary_care_incident_falls <-
  primary_care_falls_all %>%
  filter(Eventdate >= Indexdate_HFailure) %>%
  group_by(patid) %>%
  slice_min(
    order_by = Eventdate,
    n = 1,
    with_ties = FALSE
  ) %>%
  ungroup() %>%
  left_join(
    primary_care_fall_history,
    by = "patid"
  ) %>%
  transmute(
    patid,
    primary_care_fall_date = Eventdate,
    primary_care_fall = 1L,
    primary_care_fall_history
  )


#-----------------------------------------------------------
# Derive hospital-recorded fall outcomes
#-----------------------------------------------------------

hospital_falls_all <-
  admissions_raw %>%
  transmute(
    patid,
    admidate = lubridate::ymd(admidate),
    Indexdate_HFailure =
      lubridate::ymd(Indexdate_HFailure),
    ICD10 = as.character(ICD10),
    admission_type = dplyr::if_else(
      admit_type == "Emergency",
      "Emergency",
      "Elective",
      missing = "Unknown"
    )
  ) %>%
  filter(
    !is.na(patid),
    !is.na(admidate),
    !is.na(Indexdate_HFailure),
    ICD10 == "R29.6"
  ) %>%
  mutate(
    time_to_fall_years =
      as.numeric(
        difftime(
          admidate,
          Indexdate_HFailure,
          units = "days"
        )
      ) / 365.25
  )


hospital_fall_history <-
  hospital_falls_all %>%
  group_by(patid) %>%
  summarise(
    hospital_fall_history =
      ifelse(any(time_to_fall_years < 0), "Yes", "No"),
    .groups = "drop"
  )


hospital_incident_falls <-
  hospital_falls_all %>%
  filter(admidate >= Indexdate_HFailure) %>%
  group_by(patid) %>%
  slice_min(
    order_by = admidate,
    n = 1,
    with_ties = FALSE
  ) %>%
  ungroup() %>%
  left_join(
    hospital_fall_history,
    by = "patid"
  ) %>%
  transmute(
    patid,
    hospital_fall_date = admidate,
    hospital_fall = 1L,
    hospital_fall_history
  )


#-----------------------------------------------------------
# Combine primary-care and hospital fall records
#-----------------------------------------------------------

fall_features <-
  hf_cohort_base %>%
  distinct(
    patid,
    patID,
    DeathDate
  ) %>%
  left_join(
    hf_index %>%
      select(
        patid,
        patID,
        Indexdate_HFailure
      ),
    by = c("patid", "patID")
  ) %>%
  left_join(
    primary_care_incident_falls,
    by = "patid"
  ) %>%
  left_join(
    hospital_incident_falls,
    by = "patid"
  ) %>%
  mutate(
    DeathDate = lubridate::ymd(DeathDate),

    fall_history = case_when(
      primary_care_fall_history == "Yes" ~ "Yes",
      hospital_fall_history == "Yes" ~ "Yes",
      TRUE ~ "No"
    ),

    Fall_date = pmin(
      primary_care_fall_date,
      hospital_fall_date,
      na.rm = TRUE
    ),

    Fall_date = as.Date(
      ifelse(
        is.infinite(as.numeric(Fall_date)),
        NA_real_,
        as.numeric(Fall_date)
      ),
      origin = "1970-01-01"
    ),

    Fallen = ifelse(!is.na(Fall_date), 1L, 0L),

    Time_to_fall = ifelse(
      Fallen == 1L,
      as.numeric(
        difftime(
          Fall_date,
          Indexdate_HFailure,
          units = "days"
        )
      ) / 365.25,
      NA_real_
    ),

    censor_date = pmin(
      Fall_date,
      DeathDate,
      study_end_date,
      na.rm = TRUE
    ),

    followup_time =
      as.numeric(
        difftime(
          censor_date,
          Indexdate_HFailure,
          units = "days"
        )
      ) / 365.25,

    followup_time = pmax(followup_time, 0),

    Status = case_when(
      Fallen == 1L ~ 1L,
      Fallen == 0L & !is.na(DeathDate) &
        DeathDate <= study_end_date ~ 2L,
      TRUE ~ 0L
    ),

    Dead = ifelse(
      !is.na(DeathDate) &
        DeathDate <= study_end_date,
      "Dead",
      "Alive"
    )
  ) %>%
  select(
    patid,
    patID,
    Indexdate_HFailure,
    primary_care_fall_date,
    hospital_fall_date,
    Fall_date,
    Fallen,
    fall_history,
    Time_to_fall,
    followup_time,
    Status,
    Dead
  )


#-----------------------------------------------------------
# Basic validation checks
#-----------------------------------------------------------

stopifnot(
  all(fall_features$Fallen %in% c(0L, 1L)),
  all(fall_features$Status %in% c(0L, 1L, 2L)),
  all(fall_features$followup_time >= 0, na.rm = TRUE),
  !anyDuplicated(fall_features$patid),
  !anyDuplicated(bmi_features$patid)
)

if (
  any(
    fall_features$Fall_date <
      fall_features$Indexdate_HFailure,
    na.rm = TRUE
  )
) {
  stop(
    "At least one incident fall occurs before the HF index date."
  )
}


#-----------------------------------------------------------
# Save outputs
#-----------------------------------------------------------

saveRDS(
  bmi_features,
  here::here(
    "data",
    "processed",
    "bmi_features.rds"
  )
)

saveRDS(
  fall_features,
  here::here(
    "data",
    "processed",
    "fall_features.rds"
  )
)
