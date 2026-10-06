test_that("fixed month grids contain six complete weeks", {
  for (year in c(1900, 1999, 2000, 2024, 2027, 2028, 2032, 2099, 2100, 2400)) {
    for (month in seq_len(12)) {
      grid <- month_grid(year, month)
      expect_equal(nrow(grid), 42L)
      expect_equal(length(unique(grid$date)), 42L)
      expect_true(all(diff(as.integer(grid$date)) == 1L))
      expect_true(all(grid$row %in% 1:6))
      expect_true(all(grid$column %in% 1:7))
      first <- as.Date(sprintf("%04d-%02d-01", year, month))
      next_first <- if (month == 12L) as.Date(sprintf("%04d-01-01", year + 1L)) else as.Date(sprintf("%04d-%02d-01", year, month + 1L))
      expect_equal(sum(grid$in_month), as.integer(next_first - first))
      expect_true(validate_calendar_grid(grid))
    }
  }
})

test_that("compact layouts use the minimum number of complete weeks", {
  for (year in c(2024, 2027, 2100)) {
    for (month in seq_len(12)) {
      grid <- month_grid(year, month, fixed_rows = FALSE)
      expect_true(nrow(grid) %in% c(28L, 35L, 42L))
      expect_equal(nrow(grid), max(grid$row) * 7L)
      expect_true(all(diff(as.integer(grid$date)) == 1L))
    }
  }
})

test_that("all week starts align the first column and overflow visibility", {
  starts <- c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday")
  first_days <- vapply(starts, function(start) month_grid(2027, 1, start)$weekday_index[1], integer(1))
  expect_equal(unname(first_days), c(1L, 2L, 3L, 4L, 5L, 6L, 7L))
  hidden <- month_grid(2027, 1, overflow = FALSE)
  expect_equal(nrow(hidden), 42L)
  expect_true(all(!hidden$visible[!hidden$in_month]))
  expect_true(all(hidden$visible[hidden$in_month]))
  expect_true(all(month_grid(2027, 1)$visible))
})

test_that("month identity and ISO New Year fields remain explicit", {
  grid <- month_grid(2021, 1, week_start = "monday")
  jan1 <- grid[grid$date == as.Date("2021-01-01"), ]
  expect_equal(jan1$iso_week, 53L)
  expect_equal(jan1$iso_week_year, 2020L)
  expect_true(all(grid$grid_year == 2021L))
  expect_true(all(grid$grid_month == 1L))
  expect_equal(length(unique(grid$date[grid$in_month])), 31L)
})

test_that("invalid month-grid arguments are rejected", {
  expect_error(month_grid(2027, 0), "month")
  expect_error(month_grid(2027, 13), "month")
  expect_error(month_grid(2027, 1, "Mon"), "weekday")
  expect_error(month_grid(2027, 1, fixed_rows = NA), "fixed_rows")
  expect_error(month_grid(999, 1), "year")
})
