\name{last_weekday}
\alias{last_weekday}
\title{Find a Month's Last Weekday}
\description{Returns the last Monday-Friday date, or the final occurrence of a selected weekday.}
\usage{last_weekday(year, month, weekday = NULL)}
\arguments{\item{year}{Four-digit calendar year.}\item{month}{Month number from 1 through 12.}\item{weekday}{Optional full English weekday name.}}
\value{A Date.}
\examples{
last_weekday(2027, 1)
last_weekday(2027, 1, "monday")
}
