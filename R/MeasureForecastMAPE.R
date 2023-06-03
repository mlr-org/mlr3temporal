#' @title Mean Absolute Percentage Error Measure
#'
#' @name mlr_measures_forecast.mape
#' @include MeasureForecast.R
#'
#' @templateVar id forecast.mape
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureForecastMAPE = R6Class("MeasureForecastMAPE",
  inherit = MeasureForecastRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(id = "forecast.mape", msr("regr.mape"))
    }
  )
)

#' @include aaa.R
measures[["forecast.mape"]] = MeasureForecastMAPE
