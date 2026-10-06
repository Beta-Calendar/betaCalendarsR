#' Find the Nth occurrence of a weekday in a month
#'
#' @param year Four-digit calendar year.
#' @param month Month number from 1 through 12.
#' @param weekday Full English weekday name.
#' @param n Occurrence number from 1 to 5.
#'
#' @return A `Date`, or `NA` when that occurrence does not exist in the month.
#' @examples
#' nth_weekday(2027, 1, "monday", 1)
#' @export
nth_weekday <- function(year, month, weekday, n = 1L) {
  year <- .validate_year(year)
  month <- .validate_month(month)
  weekday_index <- .normalize_weekday(weekday)
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n != floor(n) || n < 1 || n > 5) {
    stop("`n` must be a whole number from 1 through 5.", call. = FALSE)
  }
  first <- .month_start(year, month)
  first_index <- .weekday_index(first)
  date <- first + ((weekday_index - first_index) %% 7L) + 7L * (as.integer(n) - 1L)
  if (as.integer(format(date, "%m")) != month) as.Date(NA) else date
}

#' Find the last occurrence of a weekday or business weekday in a month
#'
#' @param year Four-digit calendar year.
#' @param month Month number from 1 through 12.
#' @param weekday Optional full English weekday name. If omitted, return the
#'   final Monday-through-Friday date.
#'
#' @return A `Date`.
#' @examples
#' last_weekday(2027, 1)
#' last_weekday(2027, 1, "monday")
#' @export
last_weekday <- function(year, month, weekday = NULL) {
  year <- .validate_year(year)
  month <- .validate_month(month)
  date <- .month_start(year, month) + .days_in_month(year, month) - 1L
  if (is.null(weekday)) {
    while (.weekday_index(date) >= 6L) date <- date - 1L
    return(date)
  }
  weekday_index <- .normalize_weekday(weekday)
  date <- date - ((.weekday_index(date) - weekday_index) %% 7L)
  date
}

#' Generate dates for a bounded recurrence rule
#'
#' Rules are evaluated only between `from` and `to`, inclusive. Missing monthly
#' or annual dates are skipped by default; `missing = "clamp"` moves a missing
#' day to the end of that month (for example, February 29 to February 28).
#'
#' @param from First date, inclusive.
#' @param to Last date, inclusive.
#' @param frequency One of `weekly`, `monthly`, `nth_weekday`, `last_weekday`,
#'   or `annual`.
#' @param weekday Weekday used by weekly, nth-weekday, and last-weekday rules.
#'   Omit it for `last_weekday` to select the final Monday-Friday date.
#' @param day Day number for a monthly rule, from 1 through 31.
#' @param n Occurrence number for `nth_weekday`, from 1 through 5.
#' @param month_day Annual month/day in `MM-DD` form, such as `02-29`.
#' @param missing How to handle a missing monthly/annual day: `skip` or `clamp`.
#'
#' @return A date-ordered data frame with one row per recurrence and calendar metadata.
#' @examples
#' recurrence_dates(as.Date("2027-01-01"), as.Date("2027-01-31"),
#'                  frequency = "weekly", weekday = "monday")
#' @export
recurrence_dates <- function(from, to, frequency = c("weekly", "monthly", "nth_weekday", "last_weekday", "annual"),
                             weekday = NULL, day = NULL, n = 1L,
                             month_day = NULL, missing = c("skip", "clamp")) {
  range <- .validate_range(from, to)
  frequency <- match.arg(frequency)
  missing <- match.arg(missing)
  if (is.null(weekday) && frequency != "last_weekday") weekday <- "monday"
  weekday_index <- if (is.null(weekday)) NULL else .normalize_weekday(weekday)
  dates <- as.Date(character())

  if (frequency == "weekly") {
    first_index <- .weekday_index(range$from)
    first <- range$from + ((weekday_index - first_index) %% 7L)
    if (first <= range$to) dates <- seq.Date(first, range$to, by = "7 days")
  } else if (frequency == "monthly") {
    if (!is.numeric(day) || length(day) != 1L || is.na(day) || day != floor(day) || day < 1 || day > 31) {
      stop("`day` must be a whole number from 1 through 31 for monthly rules.", call. = FALSE)
    }
    months <- calendar_sequence(range$from, range$to)
    candidates <- as.Date(vapply(seq_len(nrow(months)), function(i) {
      month_days <- .days_in_month(months$year[i], months$month[i])
      if (day > month_days && missing == "skip") return(NA_real_)
      as.numeric(.month_start(months$year[i], months$month[i]) + min(as.integer(day), month_days) - 1L)
    }, numeric(1)), origin = "1970-01-01")
    dates <- candidates[!is.na(candidates)]
  } else if (frequency == "nth_weekday") {
    months <- calendar_sequence(range$from, range$to)
    candidates <- as.Date(vapply(seq_len(nrow(months)), function(i) {
      as.numeric(nth_weekday(months$year[i], months$month[i], weekday, n))
    }, numeric(1)), origin = "1970-01-01")
    dates <- candidates[!is.na(candidates)]
  } else if (frequency == "last_weekday") {
    months <- calendar_sequence(range$from, range$to)
    candidates <- as.Date(vapply(seq_len(nrow(months)), function(i) {
      if (is.null(weekday)) as.numeric(last_weekday(months$year[i], months$month[i]))
      else as.numeric(last_weekday(months$year[i], months$month[i], weekday))
    }, numeric(1)), origin = "1970-01-01")
    dates <- candidates
  } else {
    if (!is.character(month_day) || length(month_day) != 1L || is.na(month_day) ||
        !grepl("^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$", month_day)) {
      stop("`month_day` must use MM-DD form, for example '02-29'.", call. = FALSE)
    }
    month <- as.integer(substr(month_day, 1L, 2L))
    day_of_month <- as.integer(substr(month_day, 4L, 5L))
    if (day_of_month > .days_in_month(2000L, month)) {
      stop("`month_day` is not a valid Gregorian date.", call. = FALSE)
    }
    years <- seq.int(as.integer(format(range$from, "%Y")), as.integer(format(range$to, "%Y")))
    candidates <- as.Date(vapply(years, function(year) {
      month_days <- .days_in_month(year, month)
      if (day_of_month > month_days && missing == "skip") return(NA_real_)
      as.numeric(.month_start(year, month) + min(day_of_month, month_days) - 1L)
    }, numeric(1)), origin = "1970-01-01")
    dates <- candidates[!is.na(candidates)]
  }

  dates <- sort(dates[dates >= range$from & dates <= range$to])
  if (!length(dates)) return(date_range_grid(range$from, range$from)[FALSE, ])
  result <- .calendar_metadata(dates)
  result$in_month <- TRUE
  result$visible <- TRUE
  result <- result[c("date", "year", "month", "day", "weekday", "weekday_index",
                     "week", "iso_week", "iso_week_year", "row", "column",
                     "in_month", "visible", "is_weekend", "is_month_start",
                     "is_month_end", "is_year_start", "is_year_end")]
  rownames(result) <- NULL
  result
}
