#' @title Mean Squared Error Measure
#'
#' @name mlr_measures_forecast.mse
#' @include MeasureForecast.R
#'
#' @templateVar id forecast.mape
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureForecastMSE = R6Class("MeasureForecastMSE",
  inherit = MeasureForecastRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(id = "forecast.mse", msr("regr.mse"))
    }
  )
)

#' @include aaa.R
measures[["forecast.mse"]] = MeasureForecastMSE
