test_that("year grids contain twelve ordered month models", {
  year <- year_grid(2027, as = "data.frame")
  expect_equal(sort(unique(year$grid_month)), 1:12)
  expect_equal(length(unique(year$grid_year)), 1L)
  expect_true(all(year$grid_year == 2027L))
  expect_equal(length(year_grid(2027, as = "list")), 12L)
  expect_equal(names(year_grid(2027, as = "list"))[1], "January")
  expect_true(validate_calendar_grid(year))
})

test_that("date ranges include consecutive endpoints across leap and year boundaries", {
  leap <- date_range_grid(as.Date("2024-02-28"), as.Date("2024-03-01"))
  expect_equal(leap$date, as.Date(c("2024-02-28", "2024-02-29", "2024-03-01")))
  new_year <- date_range_grid(as.Date("2026-12-31"), as.Date("2027-01-02"))
  expect_equal(new_year$date, as.Date(c("2026-12-31", "2027-01-01", "2027-01-02")))
  expect_true(validate_calendar_grid(new_year))
  expect_error(date_range_grid(as.Date("2027-01-02"), as.Date("2027-01-01")), "earlier")
  expect_error(date_range_grid("2027-01-01", as.Date("2027-01-02")), "Date")
})

test_that("month sequences include both endpoint months", {
  months <- calendar_sequence(as.Date("2026-12-20"), as.Date("2027-02-10"))
  expect_equal(months$month_start, as.Date(c("2026-12-01", "2027-01-01", "2027-02-01")))
  expect_equal(months$year, c(2026L, 2027L, 2027L))
})

test_that("Gregorian leap-year rules and ISO boundary dates are correct", {
  expect_false(calendar_boundaries(1900)$is_leap_year)
  expect_true(calendar_boundaries(2000)$is_leap_year)
  expect_false(calendar_boundaries(2100)$is_leap_year)
  expect_true(calendar_boundaries(2400)$is_leap_year)
  expect_equal(calendar_boundaries(2024)$february_days, 29L)
  expect_equal(calendar_boundaries(2027)$february_days, 28L)
  expect_equal(calendar_boundaries(2027)$year_start, as.Date("2027-01-01"))
  expect_equal(calendar_boundaries(2027)$year_end, as.Date("2027-12-31"))
  expect_true(as.Date("2027-01-01") %in% calendar_boundaries(2027)$iso_crossover_dates$date)
})

test_that("calendar summaries describe row count and month length", {
  february <- calendar_summary(2024, 2)
  expect_equal(february$days_in_month, 29L)
  expect_equal(february$grid_cells, 42L)
  expect_true(february$is_leap_year)
  expect_equal(nrow(calendar_summary(2027)), 12L)
})
