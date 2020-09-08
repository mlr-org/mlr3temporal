#' @title Mean Absolute Error Measure
#'
#' @name mlr_measures_forecast.mae
#' @format [R6::R6Class()] inheriting from [MeasureForecast].
#'
#' @export
#' @include MeasureForecast.R
MeasureForecastMAE = R6Class("MeasureForecastMAE",
  inherit = MeasureForecast,
  public = list(
    initialize = function(id = "forecast.mae") {
      super$initialize(
        id = id,
        range = c(0, Inf),
        minimize = TRUE,
        packages = "mlr3forecasting"
      )
    }
  ), 

  private = list(
    .score = function(prediction, ...) {
      mean(colMeans(abs(prediction$truth[, -c("row_id"), with = F] - prediction$response[, -c("row_id"), with = F]), na.rm = TRUE))
    }
  )
)
