#' Build calendar metadata for a finite date range
#'
#' @param from First date, inclusive.
#' @param to Last date, inclusive.
#' @param week_start First weekday used for row and column coordinates.
#'
#' @return A data frame with one row for every consecutive date in the range.
#' @examples
#' dates <- date_range_grid(as.Date("2026-12-30"), as.Date("2027-01-03"))
#' dates[c("date", "year", "month", "weekday", "iso_week_year")]
#' @export
date_range_grid <- function(from, to, week_start = "monday") {
  dates <- .validate_range(from, to)
  .normalize_weekday(week_start, "week_start")
  sequence <- seq.Date(dates$from, dates$to, by = "day")
  result <- .calendar_metadata(sequence, week_start)
  result$in_month <- TRUE
  result$visible <- TRUE
  result <- result[c("date", "year", "month", "day", "weekday", "weekday_index",
                     "week", "iso_week", "iso_week_year", "row", "column",
                     "in_month", "visible", "is_weekend", "is_month_start",
                     "is_month_end", "is_year_start", "is_year_end")]
  rownames(result) <- NULL
  result
}

#' Create a sequence of month starts
#'
#' The sequence includes the month containing each endpoint, which is often the
#' useful convention when preparing monthly reports from a date interval.
#'
#' @param from First date, inclusive.
#' @param to Last date, inclusive.
#'
#' @return A data frame with one row per month and its first date.
#' @examples
#' calendar_sequence(as.Date("2026-12-20"), as.Date("2027-02-10"))
#' @export
calendar_sequence <- function(from, to) {
  range <- .validate_range(from, to)
  first <- .month_start(as.integer(format(range$from, "%Y")), as.integer(format(range$from, "%m")))
  last <- .month_start(as.integer(format(range$to, "%Y")), as.integer(format(range$to, "%m")))
  starts <- seq.Date(first, last, by = "month")
  result <- data.frame(month_start = starts,
                       year = as.integer(format(starts, "%Y")),
                       month = as.integer(format(starts, "%m")))
  rownames(result) <- NULL
  result
}
