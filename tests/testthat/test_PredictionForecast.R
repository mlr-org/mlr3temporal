context("PredictionForecast")

expect_prediction_forecast = function(p) {
  expect_prediction(p)
  checkmate::expect_r6(p, "PredictionForecast", public = c("row_ids", "response", "truth", "predict_types", "se"))
  checkmate::expect_data_table(p$truth, nrow = length(p$row_ids), types = "numeric", null.ok =TRUE)
  checkmate::expect_data_table(p$response, nrow = length(p$row_ids), types = "numeric", null.ok =TRUE)
  if ("se" %in% p$predict_types) {
    checkmate::expect_data_table(p$se, nrow = length(p$row_ids), types = "numeric", null.ok =TRUE)
  }
}

test_that("Construction", {
  task = tsk("airpassengers")
  p = PredictionForecast$new(row_ids = task$row_ids, truth = task$truth(), response = task$truth())
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



