context("Forecasting Task")

test_that("Basic properties", {
  task = tsk("airpassengers")

  expect_task(task)
  expect_task_supervised(task)

  expect_da
  dt = task$head(3)
  expect_data_table(dt, nrows = 3, ncols = 1, col.names = "named")
  dt = task$head(0L)
  expect_data_table(dt, nrows = 0, ncols = 1, col.names = "named")

  expect_numeric(task$truth(), len = task$nrow)
  expect_character(task$feature_names, len = 0)
  expect_character(task$date_col)
  expect_data_table(task$date(), nrows = 144, ncols = 1, col.names = "named")
})

test_that("printing works", {
  task = tsk("airpassengers")
  expect_output(print(task))
  expect_output(print(task$truth()))
  })


