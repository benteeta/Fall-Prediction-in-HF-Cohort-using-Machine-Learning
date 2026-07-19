required_columns <- c(id_var, index_var, "yob", "Gender")

cohort_aurum <- read_data(file_cohort_aurum)
cohort_gold  <- read_data(file_cohort_gold)

check_columns(cohort_aurum, required_columns)
check_columns(cohort_gold, required_columns)

cohort_aurum[, (id_var) := as.character(get(id_var))]
cohort_gold[, (id_var) := as.character(get(id_var))]

cohort_aurum[, pracid := substr(
  get(id_var),
  nchar(get(id_var)) - 4L,
  nchar(get(id_var))
)]

cohort_gold[, pracid := substr(
  get(id_var),
  nchar(get(id_var)) - 4L,
  nchar(get(id_var))
)]

cohort_aurum[, (index_var) := parse_date(get(index_var))]
cohort_gold[, (index_var) := parse_date(get(index_var))]

cohort_aurum[, database := "Aurum"]
cohort_gold[, database := "GOLD"]

if (cohort_aurum[, anyDuplicated(get(id_var))]) {
  stop("Duplicate patients in the Aurum cohort")
}

if (cohort_gold[, anyDuplicated(get(id_var))]) {
  stop("Duplicate patients in the GOLD cohort")
}

cohort_aurum <- cohort_aurum[
  !is.na(get(id_var)) & !is.na(get(index_var))
]

cohort_gold <- cohort_gold[
  !is.na(get(id_var)) & !is.na(get(index_var))
]

save_data(
  cohort_aurum,
  file.path(dir_derived, "hf_cohort_aurum.rds")
)

save_data(
  cohort_gold,
  file.path(dir_derived, "hf_cohort_gold.rds")
)