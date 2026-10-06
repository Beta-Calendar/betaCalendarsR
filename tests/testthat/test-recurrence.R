test_that("weekday helpers identify Nth and final weekdays", {
  expect_equal(nth_weekday(2027, 1, "monday", 1), as.Date("2027-01-04"))
  expect_equal(nth_weekday(2027, 3, "monday", 5), as.Date(NA))
  expect_equal(last_weekday(2027, 1), as.Date("2027-01-29"))
  expect_equal(last_weekday(2027, 1, "monday"), as.Date("2027-01-25"))
  expect_error(nth_weekday(2027, 1, "Mon", 1), "weekday")
})

test_that("weekly, monthly, nth, last, and annual rules stay inside bounds", {
  from <- as.Date("2027-01-01")
  to <- as.Date("2027-03-31")
  mondays <- recurrence_dates(from, to, "weekly", weekday = "monday")
  expect_true(all(mondays$weekday == "monday"))
  expect_true(all(mondays$date >= from & mondays$date <= to))

  skipped <- recurrence_dates(from, to, "monthly", day = 31, missing = "skip")
  clamped <- recurrence_dates(from, to, "monthly", day = 31, missing = "clamp")
  expect_equal(skipped$date, as.Date(c("2027-01-31", "2027-03-31")))
  expect_equal(clamped$date, as.Date(c("2027-01-31", "2027-02-28", "2027-03-31")))

  fifth_mondays <- recurrence_dates(from, to, "nth_weekday", weekday = "monday", n = 5)
  expect_equal(fifth_mondays$date, as.Date(c("2027-03-29")))
  ends <- recurrence_dates(from, to, "last_weekday")
  expect_equal(ends$date, as.Date(c("2027-01-29", "2027-02-26", "2027-03-31")))
  leap_skipped <- recurrence_dates(as.Date("2024-01-01"), as.Date("2028-12-31"), "annual", month_day = "02-29")
  expect_equal(leap_skipped$date, as.Date(c("2024-02-29", "2028-02-29")))
  leap_clamped <- recurrence_dates(as.Date("2025-01-01"), as.Date("2025-12-31"), "annual", month_day = "02-29", missing = "clamp")
  expect_equal(leap_clamped$date, as.Date("2025-02-28"))
})

test_that("recurrence arguments are validated and outputs are deterministic", {
  expect_error(recurrence_dates(as.Date("2027-01-02"), as.Date("2027-01-01")), "earlier")
  expect_error(recurrence_dates(as.Date("2027-01-01"), as.Date("2027-01-31"), "monthly"), "day")
  expect_error(recurrence_dates(as.Date("2027-01-01"), as.Date("2027-12-31"), "annual", month_day = "02-30"), "valid")
  expect_equal(recurrence_dates(as.Date("2027-01-01"), as.Date("2027-01-31"), "weekly", "sunday")$date,
               as.Date(c("2027-01-03", "2027-01-10", "2027-01-17", "2027-01-24", "2027-01-31")))
  empty <- recurrence_dates(as.Date("2027-01-01"), as.Date("2027-01-10"), "monthly", day = 31)
  expect_equal(nrow(empty), 0L)
})
