context("Forecasting Task")

test_that("has date.col", {
  task = tsk("AirPassengers")
  dt = task$head(3)
  expect_data_table(dt, nrow = 3, ncol = 1)
  # dt = task$head(0L) # This breaks
  # expect_data_table(dt, nrow = 0, ncol = 1)
})


test_that("has date.col", {

  task = tsk("AirPassengers")
  tc = task$timestamps()
  assert_class(tc, "POSIXct")
  expect_equal(task$nrow, length(tc))
})
