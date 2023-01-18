library(checkmate)
lapply(list.files(system.file("testthat", package = "mlr3"), pattern = "^helper.*\\.[rR]", full.names = TRUE), source)

expect_prediction_forecast = function(p) {
  expect_prediction(p)
  checkmate::expect_r6(p, "PredictionForecast", public = c("row_ids", "response", "truth", "predict_types", "se"))
  checkmate::expect_data_table(p$truth, nrow = length(p$row_ids), types = "numeric", null.ok = TRUE)
  if ("response" %in% p$predict_types) {
    checkmate::expect_data_table(p$response, nrow = length(p$row_ids), types = "numeric", null.ok = TRUE)
  }
  if ("se" %in% p$predict_types) {
    checkmate::expect_data_table(p$se, nrow = length(p$row_ids), types = "numeric", null.ok = TRUE)
  }
  if ("distr" %in% p$predict_types) {
    checkmate::expect_data_table(p$distr, nrow = length(p$row_ids), types = "numeric", null.ok = TRUE)
  }
}
