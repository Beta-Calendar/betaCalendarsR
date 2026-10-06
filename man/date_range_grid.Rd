\name{date_range_grid}
\alias{date_range_grid}
\title{Build Calendar Metadata for a Finite Date Range}
\description{Returns every date between two inclusive Date endpoints and adds calendar coordinates.}
\usage{date_range_grid(from, to, week_start = "monday")}
\arguments{\item{from}{First date, inclusive.}\item{to}{Last date, inclusive.}\item{week_start}{First weekday used for row and column coordinates.}}
\value{A data frame with one row for every consecutive date.}
\examples{
dates <- date_range_grid(as.Date("2026-12-30"), as.Date("2027-01-03"))
dates[c("date", "year", "month", "weekday", "iso_week_year")]
}
