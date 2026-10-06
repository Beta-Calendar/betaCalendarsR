.weekday_names <- c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday")

.validate_year <- function(year) {
  if (!is.numeric(year) || length(year) != 1L || is.na(year) || !is.finite(year) || year != floor(year) || year < 1000 || year > 9999) {
    stop("`year` must be one whole number from 1000 through 9999.", call. = FALSE)
  }
  as.integer(year)
}

.validate_month <- function(month) {
  if (!is.numeric(month) || length(month) != 1L || is.na(month) || !is.finite(month) || month != floor(month) || month < 1 || month > 12) {
    stop("`month` must be a whole number from 1 through 12.", call. = FALSE)
  }
  as.integer(month)
}

.validate_flag <- function(value, name) {
  if (!is.logical(value) || length(value) != 1L || is.na(value)) {
    stop(sprintf("`%s` must be TRUE or FALSE.", name), call. = FALSE)
  }
  value
}

.normalize_weekday <- function(weekday, name = "weekday") {
  if (!is.character(weekday) || length(weekday) != 1L || is.na(weekday)) {
    stop(sprintf("`%s` must be one weekday name.", name), call. = FALSE)
  }
  value <- tolower(weekday)
  match_value <- match(value, .weekday_names)
  if (is.na(match_value)) {
    stop(sprintf("`%s` must be one of: %s.", name, paste(.weekday_names, collapse = ", ")), call. = FALSE)
  }
  match_value
}

.validate_date <- function(date, name) {
  if (!inherits(date, "Date") || length(date) != 1L || is.na(date)) {
    stop(sprintf("`%s` must be one non-missing Date value.", name), call. = FALSE)
  }
  date
}

.weekday_index <- function(date) {
  # POSIXlt uses Sunday = 0; the package consistently exposes Monday = 1.
  wday <- as.POSIXlt(date, tz = "UTC")$wday
  ifelse(wday == 0L, 7L, as.integer(wday))
}

.iso_week_parts <- function(date) {
  weekday <- .weekday_index(date)
  thursday <- date + (4L - weekday)
  iso_year <- as.integer(format(thursday, "%Y"))
  jan4 <- as.Date(sprintf("%04d-01-04", iso_year))
  week1_monday <- jan4 - (.weekday_index(jan4) - 1L)
  list(year = iso_year,
       week = as.integer((as.integer(date) - as.integer(week1_monday)) %/% 7L + 1L))
}

.month_start <- function(year, month) as.Date(sprintf("%04d-%02d-01", year, month))

.days_in_month <- function(year, month) {
  next_month <- if (month == 12L) .month_start(year + 1L, 1L) else .month_start(year, month + 1L)
  as.integer(next_month) - as.integer(.month_start(year, month))
}

.calendar_metadata <- function(date, week_start = "monday", grid_start = NULL, requested_month = NULL) {
  week_start_index <- .normalize_weekday(week_start, "week_start")
  if (!inherits(date, "Date") || anyNA(date)) {
    stop("`date` must contain non-missing Date values.", call. = FALSE)
  }
  if (is.null(grid_start)) {
    grid_start <- date[1L] - ((.weekday_index(date[1L]) - week_start_index) %% 7L)
  }
  weekday_index <- .weekday_index(date)
  iso <- .iso_week_parts(date)
  calendar_year <- as.integer(format(date, "%Y"))
  calendar_month <- as.integer(format(date, "%m"))
  calendar_day <- as.integer(format(date, "%d"))
  month_key <- sprintf("%04d-%02d", calendar_year, calendar_month)
  if (is.null(requested_month)) {
    requested_month <- sprintf("%04d-%02d", as.integer(format(date[1L], "%Y")), as.integer(format(date[1L], "%m")))
  }
  month_start <- as.Date(paste0(month_key, "-01"))
  month_end <- as.Date(vapply(seq_along(date), function(i) {
    y <- calendar_year[i]
    m <- calendar_month[i]
    as.numeric(.month_start(y, m) + .days_in_month(y, m) - 1L)
  }, numeric(1)), origin = "1970-01-01")
  data.frame(
    date = date,
    year = calendar_year,
    month = calendar_month,
    day = calendar_day,
    weekday = .weekday_names[weekday_index],
    weekday_index = weekday_index,
    week = as.integer((as.integer(date) - as.integer(grid_start)) %/% 7L + 1L),
    iso_week = iso$week,
    iso_week_year = iso$year,
    row = as.integer((as.integer(date) - as.integer(grid_start)) %/% 7L + 1L),
    column = as.integer((weekday_index - week_start_index) %% 7L + 1L),
    in_month = month_key == requested_month,
    is_weekend = weekday_index >= 6L,
    is_month_start = date == month_start,
    is_month_end = date == month_end,
    is_year_start = format(date, "%m-%d") == "01-01",
    is_year_end = format(date, "%m-%d") == "12-31",
    stringsAsFactors = FALSE
  )
}

.validate_range <- function(from, to) {
  from <- .validate_date(from, "from")
  to <- .validate_date(to, "to")
  if (to < from) stop("`to` must not be earlier than `from`.", call. = FALSE)
  list(from = from, to = to)
}
