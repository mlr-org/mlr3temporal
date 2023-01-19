#' @title Mean Squared Error Measure
#'
#' @name mlr_measures_forecast.mse
#' @format [R6::R6Class()] inheriting from [MeasureForecastRegr].
#'
#' @export
#' @include MeasureForecast.R
MeasureForecastMSE = R6Class("MeasureForecastMSE",
  inherit = MeasureForecastRegr,
  public = list(
    initialize = function(id = "forecast.mse") {
      super$initialize(id = id, msr("regr.mse"))
    }
  )
)

#' @include aaa.R
measures[["forecast.mse"]] = MeasureForecastMSE
