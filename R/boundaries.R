#' Describe useful boundaries in a calendar year
#'
#' @param year Four-digit calendar year.
#'
#' @return A list containing year endpoints, month endpoints, leap-year facts,
#'   and dates whose ISO week-based year differs from their calendar year.
#' @examples
#' calendar_boundaries(2027)$iso_crossover_dates
#' @export
calendar_boundaries <- function(year) {
  year <- .validate_year(year)
  year_start <- as.Date(sprintf("%04d-01-01", year))
  year_end <- as.Date(sprintf("%04d-12-31", year))
  month_starts <- as.Date(sprintf("%04d-%02d-01", year, 1:12))
  month_ends <- as.Date(vapply(seq_len(12L), function(month) {
    as.numeric(.month_start(year, month) + .days_in_month(year, month) - 1L)
  }, numeric(1)), origin = "1970-01-01")
  all_dates <- seq.Date(year_start, year_end, by = "day")
  iso <- .iso_week_parts(all_dates)
  crossovers <- all_dates[iso$year != year]
  list(year = year, year_start = year_start, year_end = year_end,
       month_starts = data.frame(month = 1:12, date = month_starts),
       month_ends = data.frame(month = 1:12, date = month_ends),
       is_leap_year = as.logical((year %% 4L == 0L && year %% 100L != 0L) || year %% 400L == 0L),
       february_days = .days_in_month(year, 2L),
       iso_crossover_dates = data.frame(date = crossovers,
                                        iso_week_year = iso$year[iso$year != year],
                                        iso_week = iso$week[iso$year != year]))
}
