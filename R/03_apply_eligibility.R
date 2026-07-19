cohort_aurum <- load_data(
  file.path(dir_derived, "hf_cohort_aurum.rds")
)

cohort_gold <- load_data(
  file.path(dir_derived, "hf_cohort_gold.rds")
)

apply_eligibility <- function(data) {
  data <- copy(data)
  
  data[, yob := as.integer(yob)]
  data[, age_index := year(get(index_var)) - yob]
  
  flow <- data.table(
    stage = c(
      "HF cohort",
      "Index date within study period",
      "Valid age",
      "Unique patient"
    ),
    n = c(
      nrow(data),
      data[get(index_var) %between% c(study_start, study_end), .N],
      data[
        get(index_var) %between% c(study_start, study_end) &
          age_index %between% c(minimum_age, maximum_age),
        .N
      ],
      data[
        get(index_var) %between% c(study_start, study_end) &
          age_index %between% c(minimum_age, maximum_age),
        uniqueN(get(id_var))
      ]
    )
  )
  
  data <- data[
    get(index_var) %between% c(study_start, study_end) &
      age_index %between% c(minimum_age, maximum_age)
  ]
  
  setorderv(data, c(id_var, index_var))
  data <- unique(data, by = id_var)
  
  list(data = data, flow = flow)
}

aurum_result <- apply_eligibility(cohort_aurum)
gold_result  <- apply_eligibility(cohort_gold)

cohort_aurum <- aurum_result$data
cohort_gold  <- gold_result$data

eligibility_flow <- rbindlist(
  list(
    Aurum = aurum_result$flow,
    GOLD = gold_result$flow
  ),
  idcol = "database"
)

save_data(
  cohort_aurum,
  file.path(dir_derived, "eligible_hf_aurum.rds")
)

save_data(
  cohort_gold,
  file.path(dir_derived, "eligible_hf_gold.rds")
)

fwrite(
  eligibility_flow,
  file.path(dir_tables, "eligibility_flow.csv")
)

print(eligibility_flow)