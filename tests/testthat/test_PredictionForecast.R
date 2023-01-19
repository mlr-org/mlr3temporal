context("PredictionForecast")

test_that("Construction", {
  task = tsk("airpassengers")
  p = PredictionForecast$new(task = task, row_ids = task$row_ids, truth = task$truth(), response = task$truth())
  expect_prediction_forecast(p)
})

test_that("Confidence Intervals", {
  task = tsk("petrol")
  lrn = LearnerRegrForecastVAR$new()
  lrn$predict_type = "se"
  lrn$train(task, 1:29)
  p = lrn$predict(task, 30:40)
  ci = p$conf_int(level = 90)
  expect_list(ci, types = "data.table", len = 4L)
  expect_data_table(ci[[1]], types = "numeric")
  expect_true(all(ci[[1]][,1] > ci[[1]][,2]))
  p = PredictionForecast$new(row_ids = task$row_ids, truth = task$truth(), response = task$truth())
  expect_prediction_forecast(p)
})

test_that("Internally constructed Prediction", {
  task = tsk("airpassengers")
  lrn = lrn("forecast.average")
  lrn$train(task, 1:10)
  p = lrn$predict(task, 11:20)
  expect_prediction_forecast(p)
})

test_that("Combine Predictions", {
  task = tsk("airpassengers")
  lrn = lrn("forecast.average")
  lrn$train(task, 1:10)
  p1 = lrn$predict(task, 1:10)
  p2 = lrn$predict(task, 11:20)
  expect_prediction_forecast(c(p1, p2))

  task = tsk("petrol")
  lrn = lrn("forecast.VAR")
  lrn$predict_type = "se"
  lrn$train(task, 1:10)
  p1 = lrn$predict(task, 1:10)
  p2 = lrn$predict(task, 11:20)
  expect_prediction_forecast(c(p1, p2))
})

test_that("Fitted values", {
  task = tsk("airpassengers")
  lrn = lrn("forecast.auto_arima")
  lrn$train(task, 1:10)
  expect_data_table(lrn$fitted_values(), types = "numeric", nrows = 10)
  task = tsk("petrol")
  lrn = lrn("forecast.VAR")
  lrn$train(task, 1:10)
  expect_data_table(lrn$fitted_values(row_ids = 3:7), types = "numeric", nrows = 5, ncols = 4)
})
