\name{calendar_summary}
\alias{calendar_summary}
\title{Summarize Month-Grid Structure}
\description{Summarizes month lengths and the row counts used by calendar grids.}
\usage{calendar_summary(year, month = NULL, week_start = "monday", fixed_rows = TRUE)}
\arguments{\item{year}{Four-digit calendar year.}\item{month}{Optional month; omit to return all twelve.}\item{week_start}{First weekday in each row.}\item{fixed_rows}{Whether each grid uses six rows.}}
\value{A data frame with one row per requested month.}
\examples{calendar_summary(2027, 2)}
