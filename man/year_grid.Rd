\name{year_grid}
\alias{year_grid}
\title{Build Month Grids for a Calendar Year}
\description{Creates twelve ordered month grids with a shared week convention.}
\usage{
year_grid(
  year,
  week_start = "monday",
  fixed_rows = TRUE,
  overflow = TRUE,
  as = c("data.frame", "list")
)
}
\arguments{\item{year}{Four-digit calendar year.}\item{week_start}{First weekday in each row.}\item{fixed_rows}{Whether each month uses six rows.}\item{overflow}{Whether adjacent-month cells are visible.}\item{as}{Return a combined data frame or named list of month data frames.}}
\value{A January-to-December data frame or named list.}
\examples{
year <- year_grid(2027)
table(year$month)
months <- year_grid(2027, as = "list")
}
