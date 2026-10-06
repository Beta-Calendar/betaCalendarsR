\name{calendar_sequence}
\alias{calendar_sequence}
\title{Create a Sequence of Month Starts}
\description{Includes the month containing each endpoint of an inclusive date interval.}
\usage{calendar_sequence(from, to)}
\arguments{\item{from}{First date, inclusive.}\item{to}{Last date, inclusive.}}
\value{A data frame with one row per touched month and its first date.}
\examples{calendar_sequence(as.Date("2026-12-20"), as.Date("2027-02-10"))}
