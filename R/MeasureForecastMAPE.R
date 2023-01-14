#' @title Mean Absolute Percentage Error Measure
#'
#' @name mlr_measures_forecast.mape
#' @format [R6::R6Class()] inheriting from [MeasureForecastRegr].
#'
#' @export
#' @include MeasureForecast.R
MeasureForecastMAPE = R6Class("MeasureForecastMAPE",
  inherit = MeasureForecastRegr,
  public = list(
    initialize = function(id = "forecast.mape") {
      super$initialize(id = id, msr("regr.mape"))
    }
  )
)
