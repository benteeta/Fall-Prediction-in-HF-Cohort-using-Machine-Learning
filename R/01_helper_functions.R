check_columns <- function(data, columns) {
  missing <- setdiff(columns, names(data))
  if (length(missing)) stop("Missing columns: ", paste(missing, collapse = ", "))
}

parse_date <- function(x) {
  if (inherits(x, "Date")) return(as.IDate(x))
  
  as.IDate(parse_date_time(trimws(as.character(x)),
    orders = c("ymd", "dmy"),  quiet = TRUE
  ))
}

read_data <- function(file, select = NULL) {
  fread(file, select = select,integer64 = "character",  showProgress = TRUE)
}


read_files <- function(files, select = NULL) {
  rbindlist(
    lapply(files, read_data, select = select),
    use.names = TRUE,
    fill = TRUE
  )
}

save_data <- function(data, file) {
  saveRDS(data, file, compress = FALSE)
}

load_data <- function(file) {
  readRDS(file)
}

latest_before <- function(data, id, date, index) {
  setorderv(data, c(id, date))
  data[get(date) <= get(index), .SD[.N], by = id]
}