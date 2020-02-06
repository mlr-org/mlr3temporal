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

test_that("Internally constructed Prediction", {
  task = tsk("airpassengers")
  lrn = lrn("forecast.average")
  lrn$train(task)
  p = lrn$predict(task)
  expect_prediction_forecast(p)
})