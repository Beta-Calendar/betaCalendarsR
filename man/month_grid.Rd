\name{month_grid}
\alias{month_grid}
\title{Build a Deterministic Month Calendar Grid}
\description{Creates complete calendar weeks for one month. Adjacent-month dates keep their positions so weekday columns remain stable.}
\usage{month_grid(year, month, week_start = "monday", fixed_rows = TRUE, overflow = TRUE)}
\arguments{\item{year}{Four-digit calendar year.}\item{month}{Month number from 1 through 12.}\item{week_start}{First weekday in each row; any full weekday name is accepted.}\item{fixed_rows}{If true, return six complete rows; otherwise return the minimum complete number of weeks.}\item{overflow}{If false, adjacent-month cells remain in the grid but have visible set to false.}}
\value{A data frame with one row per date cell, including date, calendar, ISO week, row/column, visibility, and boundary fields.}
\examples{
january <- month_grid(2027, 1, week_start = "monday")
nrow(january)
sum(january$in_month)
}
