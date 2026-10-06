\name{recurrence_dates}
\alias{recurrence_dates}
\title{Generate Dates for a Bounded Recurrence Rule}
\description{Evaluates a weekly, monthly, nth-weekday, last-weekday, or annual date rule only within an explicit inclusive range.}
\usage{
recurrence_dates(
  from,
  to,
  frequency = c("weekly", "monthly", "nth_weekday", "last_weekday", "annual"),
  weekday = NULL,
  day = NULL,
  n = 1L,
  month_day = NULL,
  missing = c("skip", "clamp")
)
}
\arguments{\item{from}{First date, inclusive.}\item{to}{Last date, inclusive.}\item{frequency}{Recurrence kind.}\item{weekday}{Full English weekday name where used.}\item{day}{Day number for monthly rules.}\item{n}{Occurrence number for nth-weekday rules.}\item{month_day}{Annual month/day in MM-DD form.}\item{missing}{Skip or clamp a missing monthly or annual date.}}
\value{A date-ordered data frame with one row per recurrence and calendar metadata.}
\examples{
recurrence_dates(as.Date("2027-01-01"), as.Date("2027-01-31"),
  frequency = "weekly", weekday = "monday")
}
