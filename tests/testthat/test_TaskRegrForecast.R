context("Forecasting Task")

test_that("Basic properties", {
  task = tsk("AirPassengers")
  dt = task$head(3)
  expect_data_table(dt, nrow = 3, ncol = 1, col.names = "named")
  dt = task$head(0L)
  expect_data_table(dt, nrow = 0, ncol = 1, col.names = "named")

  expect_numeric(task$truth(), len = task$nrow)
  expect_character(task$feature_names, len = 0)
  expect_character(task$date_col)
  expect_data_table(task$date(), nrow = 144, ncol = 1, col.names = "named")
})
