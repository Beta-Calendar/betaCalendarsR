# betaCalendarsR

<!-- badges: start -->
<!-- badges: end -->

`betaCalendarsR` turns base R `Date` values into predictable calendar data
frames. It provides month and year grids, date-range metadata, ISO week values,
calendar boundaries, and finite recurrence helpers without a runtime dependency
on a UI toolkit or the Beta Calendars website.

## Why this package exists

Date arithmetic and calendar layout are separate jobs. A `Date` can identify a
day, but reporting and planning code still needs to choose a week start, decide
how to represent days outside a month, and label weeks around New Year. This
package makes those choices explicit in a base `data.frame`, so the same model
can feed a report, dashboard, Shiny view, test fixture, or static document.

## Installation

```r
install.packages(
  "betaCalendarsR",
  repos = c(
    "https://betacalendars.r-universe.dev",
    "https://cloud.r-project.org"
  )
)
```

## Quick start

```r
library(betaCalendarsR)

january <- month_grid(2027, 1, week_start = "monday", fixed_rows = TRUE)
stopifnot(nrow(january) == 42L)
january[january$in_month, c("date", "weekday", "iso_week")]
```

Rows are consecutive dates. `grid_year` and `grid_month` retain each requested
month's identity, including in a combined year table. `row` and `column` give
stable calendar positions;
`iso_week` and `iso_week_year` follow ISO-8601 even when the week-based year
differs from the calendar year.

## Week starts and overflow cells

All seven full weekday names are accepted. The names are case-insensitive, and
invalid values raise an error.

```r
monday_first <- month_grid(2027, 1, week_start = "monday")
sunday_first <- month_grid(2027, 1, week_start = "sunday")
saturday_first <- month_grid(2027, 1, week_start = "saturday")
```

With `fixed_rows = TRUE`, each month contains six complete rows (42 cells).
With `fixed_rows = FALSE`, the grid contains the minimum complete number of
weeks. `overflow = FALSE` keeps adjacent-month dates in their positions but
marks them `visible = FALSE`; this preserves weekday alignment and row count.

## Full-year calendar data

`year_grid()` returns a combined data frame by default, ordered from January to
December. Use `as = "list"` when separate month tables are more convenient.

```r
year <- year_grid(2027, week_start = "monday", fixed_rows = FALSE)
table(year$month)
months <- year_grid(2027, as = "list")
```

## Date ranges and boundaries

`date_range_grid()` includes both endpoints and every intervening date.
`calendar_sequence()` returns the first day of each month touched by an
inclusive interval. `calendar_boundaries()` reports month endpoints, leap-year
facts, and dates whose ISO week-based year differs from the requested year.

```r
range <- date_range_grid(as.Date("2026-12-30"), as.Date("2027-01-03"))
range[c("date", "year", "month", "iso_week", "iso_week_year")]

calendar_boundaries(2027)$iso_crossover_dates
```

## Recurrence rules

Every recurrence requires a finite `from` and `to` range. Monthly rules skip a
missing day by default or clamp it to month end when requested. Annual
`02-29` rules similarly skip common years or clamp to February 28.

```r
mondays <- recurrence_dates(
  as.Date("2027-01-01"), as.Date("2027-01-31"),
  frequency = "weekly", weekday = "monday"
)

month_ends <- recurrence_dates(
  as.Date("2027-01-01"), as.Date("2027-03-31"),
  frequency = "monthly", day = 31, missing = "clamp"
)

leap_days <- recurrence_dates(
  as.Date("2024-01-01"), as.Date("2028-12-31"),
  frequency = "annual", month_day = "02-29", missing = "skip"
)
```

`nth_weekday()` returns `NA` when the requested fifth occurrence does not exist.
`last_weekday()` returns the final Monday-Friday date when no weekday is given,
or the final occurrence of a selected weekday otherwise.

## Testing calendar software

`validate_calendar_grid()` checks that dates are unique, consecutive, and in
ascending order, and that row/column coordinates are valid. This is useful for
asserting invariants before a calendar data frame is passed to a renderer.

## Design notes

Month grids retain leading and trailing dates to keep columns aligned. This
matches the structural needs of [month-based calendar layouts](https://www.betacalendars.com/monthly-calendar).
The same cells can describe blank states for [printable calendar layouts](https://www.betacalendars.com/blank-calendar),
while date-range helpers suit [week-oriented calendar views](https://www.betacalendars.com/weekly-calendar).
These links provide layout context; the package does not fetch or depend on
website content.

## Contributing

Please open an issue for a proposed behavior change before submitting a pull
request. Run `R CMD check --as-cran` and the testthat suite before submitting.

## License

MIT. See `LICENSE`.

## Project

Maintained by [Beta Calendars](https://www.betacalendars.com/). Source and issue
tracking are on [GitHub](https://github.com/betacalendars/betaCalendarsR).
