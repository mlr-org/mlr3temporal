context("Forecasting Task")

test_that("Basic properties", {
  task = tsk("airpassengers")


  expect_task(task)
  expect_task_supervised(task)


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


test_that("task data has expected column names", {
  data = data.table(target = rnorm(30), exo1 = rnorm(30))
  task = TaskRegrForecast$new(id = "test", backend = ts(data), target = "target")
  expect_equal(colnames(data), colnames(task$data()))
})

test_that("task data has expected column types", {

  data = data.table(target = rnorm(30), exo1 = rnorm(30))
  task = TaskRegrForecast$new(id = "test",
                              backend = ts(data),
                              target = "target")

  expect_equal(task$col_info[colnames(data)[1], type], class(data[[1]]))
  expect_equal(task$col_info[colnames(data)[2], type], class(data[[2]]))
})

test_that("construction from data frame", {
  data = data.frame(a = runif(1:100), b = runif(1:100), t = Sys.time() + 1:100)
  task = TaskRegrForecast$new(id = "df", backend = data, target = c("a", "b"), date_col = "t")
  expect_task(task)
  expect_true("multivariate" %in% task$properties)

  data = data.frame(a = runif(1:100), b=runif(1:100), t = Sys.time()+ 1:100)
  task = TaskRegrForecast$new(id = "df", backend = data, target = c("a"), date_col = "t")
  expect_task(task)
  expect_true("univariate" %in% task$properties)
})

test_that("Target name for single timeseries", {
  task = TaskRegrForecast$new(id = "target_names", backend = mdeaths, target ="abc" )
  expect_equal(task$target_names, "abc")
})
