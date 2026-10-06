#' Build all twelve month grids for a year
#'
#' @param year Four-digit calendar year.
#' @param week_start First weekday in each month row.
#' @param fixed_rows Whether every month has six rows.
#' @param overflow Whether adjacent-month cells are visible.
#' @param as Return a combined `data.frame` or a named list of month data frames.
#'
#' @return A data frame or a named list in January-to-December order.
#' @examples
#' year <- year_grid(2027)
#' table(year$month)
#' @export
year_grid <- function(year, week_start = "monday", fixed_rows = TRUE,
                      overflow = TRUE, as = c("data.frame", "list")) {
  year <- .validate_year(year)
  .normalize_weekday(week_start, "week_start")
  fixed_rows <- .validate_flag(fixed_rows, "fixed_rows")
  overflow <- .validate_flag(overflow, "overflow")
  as <- match.arg(as)
  month_names <- c("January", "February", "March", "April", "May", "June",
                   "July", "August", "September", "October", "November", "December")
  grids <- lapply(seq_len(12L), function(month) {
    month_grid(year, month, week_start, fixed_rows, overflow)
  })
  names(grids) <- month_names
  if (as == "list") return(grids)
  result <- do.call(rbind, grids)
  rownames(result) <- NULL
  result
}
