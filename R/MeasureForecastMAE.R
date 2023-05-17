#' @title Mean Absolute Error Measure
#'
#' @name mlr_measures_forecast.mae
#'
#' @export
#' @include MeasureForecast.R
MeasureForecastMAE = R6Class("MeasureForecastMAE",
  inherit = MeasureForecastRegr,
  public = list(
    initialize = function(id = "forecast.mae") {
      super$initialize(id = id, msr("regr.mae"))
    }
  )
)

#' @include aaa.R
measures[["forecast.mae"]] = MeasureForecastMAE
