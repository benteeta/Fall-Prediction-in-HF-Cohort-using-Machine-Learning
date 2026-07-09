############################################################
# Project: Fall Prediction in Heart Failure Cohort using Machine Learning
# Purpose: Store reusable helper functions used across the analytic pipeline.
############################################################

#-----------------------------------------------------------
# Read all sheets from an Excel workbook and combine rows
#-----------------------------------------------------------

read_excel_sheets <- function(file_path) {
  sheets <- readxl::excel_sheets(file_path)
  sheet_list <- lapply(sheets,
    function(sheet) {readxl::read_excel(file_path, sheet = sheet)
    }
  )
 dplyr::bind_rows(sheet_list)
}


#-----------------------------------------------------------
# Recode ethnicity into broad groups
#-----------------------------------------------------------

recode_ethnicity <- function(x) {
  dplyr::case_when(
    x %in% c(
      "Bangladeshi", "Bangladesi", "Chinese", "Indian",
      "Oth_Asian", "Pakistani", "Other Asian"
    ) ~ "Asian",

    x %in% c(
      "Bl_Afric", "Bl_Carib", "Bl_Other",
      "Caribbean", "Mixed"
    ) ~ "Black",

    x %in% c(
      "Missing", "Not mentioned", "Other", "Unknown"
    ) ~ "Others",

    TRUE ~ as.character(x)
  )
}


#-----------------------------------------------------------
# Create age groups
#-----------------------------------------------------------

create_age_group <- function(age) {
  dplyr::case_when(
    age < 51 ~ "40-50",
    age < 56 ~ "51-55",
    age < 61 ~ "56-60",
    age < 66 ~ "61-65",
    age < 71 ~ "66-70",
    age < 76 ~ "71-75",
    age < 81 ~ "76-80",
    age < 86 ~ "81-85",
    age < 91 ~ "86-90",
    TRUE ~ "91+"
  )
}


#-----------------------------------------------------------
# Collapse age groups for dashboard and reporting
#-----------------------------------------------------------

collapse_age_group <- function(age_group) {
  dplyr::case_when(
    age_group %in% c("40-50") ~ "40-50",
    age_group %in% c("51-55", "56-60") ~ "51-60",
    age_group %in% c("61-65", "66-70") ~ "61-70",
    age_group %in% c("71-75", "76-80") ~ "71-80",
    age_group %in% c("81-85", "86-90") ~ "81-90",
    TRUE ~ "91+"
  )
}


#-----------------------------------------------------------
# Collapse IMD deciles into quintile-style groups
#-----------------------------------------------------------

collapse_imd <- function(imd) {
  imd <- as.character(imd)

  dplyr::case_when(
    imd %in% c("1", "2") ~ "1",
    imd %in% c("3", "4") ~ "2",
    imd %in% c("5", "6") ~ "3",
    imd %in% c("7", "8") ~ "4",
    imd %in% c("9", "10") ~ "5",
    TRUE ~ NA_character_
  )
}


#-----------------------------------------------------------
# Convert BMI into clinical categories
#-----------------------------------------------------------

categorise_bmi <- function(bmi) {
  dplyr::case_when(
    bmi < 18.5 ~ "Underweight",
    bmi < 25.0 ~ "Healthy",
    bmi < 30.0 ~ "Overweight",
    bmi < 40.0 ~ "Obese",
    bmi >= 40.0 ~ "Severe Obesity",
    TRUE ~ NA_character_
  )
}


#-----------------------------------------------------------
# Convert eFI score into frailty category
#-----------------------------------------------------------

categorise_frailty <- function(efi) {
  dplyr::case_when(
    efi < 0.121 ~ "Fit",
    efi < 0.241 ~ "Mild",
    efi < 0.361 ~ "Moderate",
    efi >= 0.361 ~ "Severe",
    TRUE ~ NA_character_
  )
}


#-----------------------------------------------------------
# Impute missing values in external data using training data
#-----------------------------------------------------------

impute_external <- function(newdata, refdata) {
  out <- data.table::copy(newdata)

  for (col in names(refdata)) {
    if (is.numeric(refdata[[col]])) {
      med <- stats::median(refdata[[col]], na.rm = TRUE)
      out[[col]][is.na(out[[col]])] <- med
    } else {
      refdata[[col]] <- as.factor(refdata[[col]])
      levs <- levels(refdata[[col]])
      out[[col]] <- factor(out[[col]], levels = levs)

      mode_val <- names(sort(table(refdata[[col]]), decreasing = TRUE))[1]
      out[[col]][is.na(out[[col]])] <- mode_val
    }
  }

  out
}


#-----------------------------------------------------------
# Evaluate binary prediction model performance
#-----------------------------------------------------------

evaluate_binary_model <- function(y_true, y_prob, threshold = 0.5) {
  roc_obj <- pROC::roc(
    y_true,
    y_prob,
    levels = c("No", "Yes"),
    quiet = TRUE
  )

  auc_val <- as.numeric(pROC::auc(roc_obj))
  auc_ci <- as.numeric(pROC::ci.auc(roc_obj, method = "delong"))

  y_pred <- factor(
    ifelse(y_prob >= threshold, "Yes", "No"),
    levels = c("No", "Yes")
  )

  cm <- caret::confusionMatrix(
    y_pred,
    y_true,
    positive = "Yes"
  )

  y_bin <- ifelse(y_true == "Yes", 1, 0)
  brier <- mean((y_prob - y_bin)^2)

  data.frame(
    AUC = round(auc_val, 3),
    AUC_Lower95 = round(auc_ci[1], 3),
    AUC_Upper95 = round(auc_ci[3], 3),
    Threshold = round(threshold, 3),
    Accuracy = round(unname(cm$overall["Accuracy"]), 3),
    Sensitivity = round(unname(cm$byClass["Sensitivity"]), 3),
    Specificity = round(unname(cm$byClass["Specificity"]), 3),
    Brier = round(brier, 3)
  )
}


#-----------------------------------------------------------
# Extract cumulative incidence estimate at a specific time
#-----------------------------------------------------------

get_cif_at_time <- function(cif, time_point) {
  if (all(cif$time > time_point)) {
    return(0)
  }

  cif$est[max(which(cif$time <= time_point))]
}


#-----------------------------------------------------------
# Scale individual model scores to time-specific risks
#-----------------------------------------------------------

scale_time_specific_risk <- function(individual_score, baseline_risk, mean_score) {
  pmin((individual_score / mean_score) * baseline_risk, 1)
}
