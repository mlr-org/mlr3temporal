#' @title Mean Absolute Error Measure
#'
#' @name mlr_measures_forecast.mae
#' @include MeasureForecast.R
#'
#' @templateVar id forecast.mape
#' @template measure
#'
#' @template seealso_measure
#' @export
MeasureForecastMAE = R6Class("MeasureForecastMAE",
  inherit = MeasureForecastRegr,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(id = "forecast.mae", msr("regr.mae"))
    }
  )
)

#' @include aaa.R
measures[["forecast.mae"]] = MeasureForecastMAE
