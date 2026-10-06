\name{calendar_boundaries}
\alias{calendar_boundaries}
\title{Describe Boundaries in a Calendar Year}
\description{Reports year and month endpoints, Gregorian leap-year facts, and ISO week-year crossover dates.}
\usage{calendar_boundaries(year)}
\arguments{\item{year}{Four-digit calendar year.}}
\value{A list of year dates, month endpoint tables, leap-year information, and ISO crossover dates.}
\examples{calendar_boundaries(2027)$iso_crossover_dates}
