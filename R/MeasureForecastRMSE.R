#' @title Root Mean Squared Error Measure
#'
#' @name mlr_measures_forecast.rmse
#' @include MeasureForecast.R
#'
#' @templateVar id forecast.rmse
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureForecastRMSE = R6Class("MeasureForecastRMSE",
  inherit = MeasureForecastRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(id = "forecast.rmse", msr("regr.rmse"))
    }
  )
)

#' @include aaa.R
measures[["forecast.rmse"]] = MeasureForecastRMSE
