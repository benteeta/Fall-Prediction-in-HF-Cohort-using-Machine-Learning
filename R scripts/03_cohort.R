############################################################
# Project: Fall Prediction in Heart Failure Cohort using Machine Learning
#
# Purpose: Create the base heart failure cohort and derive annual follow-up structure from heart failure diagnosis onwards.
#
# Inputs:
# - data/processed/patient_data_raw.rds
# - data/processed/index_dates_raw.rds
#
# Outputs:
# - data/processed/hf_cohort_base.rds
# - data/processed/mltc_annual.rds
############################################################

source(here::here("R", "01_load_libraries.R"))
source(here::here("R", "helper_functions.R"))


#-----------------------------------------------------------
# Load imported data
#-----------------------------------------------------------

patient_data <- readRDS(here::here("data", "processed", "patient_data_raw.rds"))
index_dates  <- readRDS(here::here("data", "processed", "index_dates_raw.rds"))


#-----------------------------------------------------------
# Prepare patient demographics
#-----------------------------------------------------------
patient_base <- patient_data %>%  mutate(current_year = as.numeric(format(Sys.Date(), "%Y")),
    age = current_year - as.numeric(birthyear),
    ethnicgroup = recode_ethnicity(ethnicgroup),
    smoking = ifelse(is.na(smoking), "Non-smoker", smoking),
    alcohol = ifelse(is.na(alcohol), "Non drinker", alcohol)) %>%
  select(patid, patID, sex, Region, age, ethnicgroup, index_of_multiple_deprivation, smoking, alcohol, DeathDate) %>% distinct()

#-----------------------------------------------------------
# Multiple long-term conditions
#-----------------------------------------------------------
index_dates_clean <- index_dates %>% mutate(across(everything(), as.character)) %>%  select(-any_of(c("Indexdate_Fall", "Indexdate_Fracture")))
date_cols <- grep("^Indexdate_", names(index_dates_clean), value = TRUE)
index_dates_clean <-  index_dates_clean %>%  mutate(across(all_of(date_cols), lubridate::ymd))
hf_index <-  index_dates_clean %>%  select(patID, patid, Indexdate_HFailure)
#-----------------------------------------------------------
# Create annual patient follow-up grid
#-----------------------------------------------------------
patient_year_range <-  index_dates_clean %>%  rowwise() %>%  mutate(minyr = min(lubridate::year(c_across(all_of(date_cols))), na.rm = TRUE),  maxyr = 2023) %>%
  ungroup() %>% select(patID, minyr, maxyr)
annual_grid <-  patient_year_range %>%  rowwise() %>%  mutate(year = list(seq(minyr, maxyr))) %>%  unnest(year) %>%  ungroup() %>%  select(patID, year) %>%
  mutate(year = as.numeric(year))


#-----------------------------------------------------------
# Derive annual long-term condition count
#-----------------------------------------------------------

mltc_long <-
  index_dates_clean %>%
  mutate(
    minyr = apply(
      select(., all_of(date_cols)),
      1,
      function(x) min(lubridate::year(x), na.rm = TRUE)
    ),
    maxyr = 2023
  ) %>%
  rowwise() %>%
  mutate(year = list(seq(minyr, maxyr))) %>%
  unnest(year) %>%
  ungroup() %>%
  mutate(
    years_withHFdiag = year - lubridate::year(Indexdate_HFailure)
  ) %>%
  pivot_longer(
    cols = all_of(date_cols),
    names_to = "condition_type",
    values_to = "condition_date"
  ) %>%
  mutate(
    condition_type = stringr::str_remove(condition_type, "^Indexdate_"),
    condition = ifelse(
      lubridate::year(condition_date) == year,
      condition_type,
      NA_character_
    )
  ) %>%
  filter(!is.na(condition)) %>%
  select(patID, year, years_withHFdiag, condition) %>%
  pivot_wider(
    names_from = condition,
    values_from = condition
  )


mltc_wide <-
  annual_grid %>%
  left_join(mltc_long, by = c("patID", "year")) %>%
  group_by(patID) %>%
  tidyr::fill(-year, .direction = "down") %>%
  ungroup()

condition_cols <- setdiff(
  names(mltc_wide),
  c("patID", "year", "years_withHFdiag")
)

mltc_annual <-
  mltc_wide %>%
  mutate(
    nMLTCs = rowSums(!is.na(across(all_of(condition_cols)))),
    nMLTCs = ifelse(!is.na(HFailure), nMLTCs - 1, nMLTCs)
  ) %>%
  select(patID, year, years_withHFdiag, nMLTCs)


#-----------------------------------------------------------
# Restrict to years after heart failure diagnosis
#-----------------------------------------------------------

hf_years <-
  patient_base %>%
  select(patid, patID) %>%
  left_join(hf_index, by = c("patid", "patID")) %>%
  left_join(annual_grid, by = "patID") %>%
  mutate(
    Indexdate_HFailure = lubridate::ymd(Indexdate_HFailure),
    years_withHFdiag = year - lubridate::year(Indexdate_HFailure)
  ) %>%
  filter(years_withHFdiag > -1) %>%
  select(-Indexdate_HFailure)


hf_cohort_base <-
  patient_base %>%
  left_join(hf_years, by = c("patid", "patID")) %>%
  filter(!is.na(years_withHFdiag)) %>%
  distinct()


#-----------------------------------------------------------
# Save outputs
#-----------------------------------------------------------

saveRDS(
  hf_cohort_base,
  here::here("data", "processed", "hf_cohort_base.rds")
)

saveRDS(
  mltc_annual,
  here::here("data", "processed", "mltc_annual.rds")
)
