#' Validate a calendar-grid data frame
#'
#' Checks the structural invariants used by this package: unique Date values,
#' consecutive dates, and valid one-based row and column coordinates.
#'
#' @param x A data frame returned by `month_grid()`, `year_grid()`, or
#'   `date_range_grid()`.
#'
#' @return `TRUE` invisibly when valid; otherwise, an informative error is raised.
#' @examples
#' validate_calendar_grid(month_grid(2027, 1))
#' @export
validate_calendar_grid <- function(x) {
  required <- c("date", "row", "column", "weekday_index")
  if (!is.data.frame(x) || !all(required %in% names(x))) {
    stop("`x` must be a calendar data frame with date, row, column, and weekday_index columns.", call. = FALSE)
  }
  if (!inherits(x$date, "Date") || anyNA(x$date)) stop("`date` must contain non-missing Date values.", call. = FALSE)
  if (anyNA(x$row) || any(x$row < 1L) || anyNA(x$column) || any(x$column < 1L | x$column > 7L)) {
    stop("Calendar row and column coordinates are outside their valid ranges.", call. = FALSE)
  }
  if (anyNA(x$weekday_index) || any(x$weekday_index < 1L | x$weekday_index > 7L)) {
    stop("`weekday_index` must be between 1 and 7.", call. = FALSE)
  }
  if (all(c("grid_year", "grid_month") %in% names(x))) {
    groups <- split(seq_len(nrow(x)), interaction(x$grid_year, x$grid_month, drop = TRUE))
    for (indices in groups) {
      dates <- x$date[indices]
      if (anyDuplicated(dates)) stop("Dates must not be duplicated within a month grid.", call. = FALSE)
      if (!identical(dates, sort(dates))) stop("Dates within a month grid must be in ascending order.", call. = FALSE)
      if (length(dates) > 1L && any(diff(as.integer(dates)) != 1L)) {
        stop("Dates within a month grid must be consecutive.", call. = FALSE)
      }
    }
  } else if (anyDuplicated(x$date)) {
    stop("Calendar dates must not be duplicated.", call. = FALSE)
  }
  if (nrow(x) > 1L && !all(c("grid_year", "grid_month") %in% names(x))) {
    ordered_dates <- sort(x$date)
    if (any(diff(as.integer(ordered_dates)) != 1L)) stop("Calendar dates must be consecutive.", call. = FALSE)
    if (!identical(x$date, ordered_dates)) stop("Calendar dates must be in ascending order.", call. = FALSE)
  }
  invisible(TRUE)
}
