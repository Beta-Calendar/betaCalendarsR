#' Build a deterministic month calendar grid
#'
#' Creates a data frame of complete calendar weeks for a month. Adjacent-month
#' dates remain as cells in the grid; `overflow = FALSE` marks those cells as
#' invisible rather than shifting the weekday columns.
#'
#' @param year Four-digit calendar year.
#' @param month Month number from 1 through 12.
#' @param week_start First weekday in each row. Accepts any full weekday name.
#' @param fixed_rows If `TRUE`, return six complete rows (42 cells). Otherwise,
#'   return the minimum number of complete weeks needed by the month.
#' @param overflow If `TRUE`, adjacent-month cells are visible; if `FALSE`,
#'   they remain in the grid with `visible = FALSE`.
#'
#' @return A data frame with one row per date cell, weekday and week coordinates,
#'   ISO week fields, month membership, visibility, and boundary indicators.
#' @examples
#' january <- month_grid(2027, 1, week_start = "monday")
#' nrow(january)
#' sum(january$in_month)
#' @export
month_grid <- function(year, month, week_start = "monday", fixed_rows = TRUE, overflow = TRUE) {
  year <- .validate_year(year)
  month <- .validate_month(month)
  week_start_index <- .normalize_weekday(week_start, "week_start")
  fixed_rows <- .validate_flag(fixed_rows, "fixed_rows")
  overflow <- .validate_flag(overflow, "overflow")
  first <- .month_start(year, month)
  leading <- (.weekday_index(first) - week_start_index) %% 7L
  days <- .days_in_month(year, month)
  rows <- if (fixed_rows) 6L else as.integer(ceiling((leading + days) / 7))
  grid_start <- first - leading
  dates <- seq.Date(grid_start, by = "day", length.out = rows * 7L)
  requested_month <- sprintf("%04d-%02d", year, month)
  result <- .calendar_metadata(dates, week_start, grid_start, requested_month)
  result$grid_year <- year
  result$grid_month <- month
  result$visible <- overflow | result$in_month
  result <- result[c("date", "year", "month", "day", "grid_year", "grid_month", "weekday", "weekday_index",
                     "week", "iso_week", "iso_week_year", "row", "column",
                     "in_month", "visible", "is_weekend", "is_month_start",
                     "is_month_end", "is_year_start", "is_year_end")]
  rownames(result) <- NULL
  result
}

#' Summarize month-grid structure
#'
#' @param year Four-digit calendar year.
#' @param month Optional month number. If omitted, summarize all twelve months.
#' @param week_start First weekday in each row.
#' @param fixed_rows Whether to use six rows per month.
#'
#' @return A data frame with month length, row and cell counts, and first-day information.
#' @examples
#' calendar_summary(2027, 2)
#' @export
calendar_summary <- function(year, month = NULL, week_start = "monday", fixed_rows = TRUE) {
  year <- .validate_year(year)
  .normalize_weekday(week_start, "week_start")
  fixed_rows <- .validate_flag(fixed_rows, "fixed_rows")
  months <- if (is.null(month)) 1:12 else .validate_month(month)
  pieces <- lapply(months, function(m) {
    grid <- month_grid(year, m, week_start = week_start, fixed_rows = fixed_rows)
    data.frame(year = year, month = m, days_in_month = .days_in_month(year, m),
               grid_rows = max(grid$row), grid_cells = nrow(grid),
               first_weekday = grid$weekday[which(grid$is_month_start)[1L]],
               is_leap_year = as.logical((year %% 4L == 0L && year %% 100L != 0L) || year %% 400L == 0L),
               stringsAsFactors = FALSE)
  })
  result <- do.call(rbind, pieces)
  rownames(result) <- NULL
  result
}
