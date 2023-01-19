#' @title Root Mean Squared Error Measure
#'
#' @name mlr_measures_forecast.rmse
#' @format [R6::R6Class()] inheriting from [MeasureForecastRegr].
#'
#' @export
#' @include MeasureForecast.R
MeasureForecastRMSE = R6Class("MeasureForecastRMSE",
  inherit = MeasureForecastRegr,
  public = list(
    initialize = function(id = "forecast.rmse") {
      super$initialize(id = id, msr("regr.rmse"))
    }
  )
)

#' @include aaa.R
measures[["forecast.rmse"]] = MeasureForecastRMSE
