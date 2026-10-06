\name{nth_weekday}
\alias{nth_weekday}
\title{Find the Nth Weekday in a Month}
\description{Computes a selected occurrence without silently rolling an absent fifth weekday into the following month.}
\usage{nth_weekday(year, month, weekday, n = 1L)}
\arguments{\item{year}{Four-digit calendar year.}\item{month}{Month number from 1 through 12.}\item{weekday}{Full English weekday name.}\item{n}{Occurrence number from 1 through 5.}}
\value{A Date, or NA when that occurrence does not exist.}
\examples{nth_weekday(2027, 1, "monday", 1)}
