\name{validate_calendar_grid}
\alias{validate_calendar_grid}
\title{Validate a Calendar-Grid Data Frame}
\description{Checks date, row, and column invariants for a calendar data frame.}
\usage{validate_calendar_grid(x)}
\arguments{\item{x}{A data frame returned by month_grid, year_grid, or date_range_grid.}}
\value{TRUE invisibly when valid; otherwise raises an informative error.}
\examples{validate_calendar_grid(month_grid(2027, 1))}
