#' @title Forecast Regression Measure
#'
#' @description
#' This measure specializes [mlr3::Measure] for forecast regression problems.
#' The `task_type` is set to `"forecast"`.
#'
#' @section Construction:
#' ```
#' m = MeasureForecast$new(id, range, minimize, predict_type = "response",
#'      task_properties = character(0L), packages = character(0L))
#' ```
#' For a description of the arguments, see [mlr3::Measure].
#' The `task_type` is set to `"forecast"`.
#' Possible values for `predict_types` is "response" and "se".
#'
#' @section Fields:
#' See [Measure].
#'
#' @section Methods:
#' See [Measure].
#'
#' @family Measure
#' @export
MeasureForecast = R6Class("MeasureForecast",
  inherit = Measure,
  cloneable = FALSE,
  public = list(
    initialize = function(id,
                          range,
                          minimize = NA,
                          average = "macro",
                          aggregator = NULL,
                          properties = character(),
                          predict_type = "response",
                          predict_sets = "test",
                          task_properties = character(),
                          packages = character(),
                          man = NA_character_) {
      super$initialize(
        id,
        task_type = "forecast",
        range = range,
        minimize = minimize,
        average = average,
        aggregator = aggregator,
        properties = properties,
        predict_type = predict_type,
        predict_sets = predict_sets,
        task_properties = task_properties,
        packages = packages,
        man = man
      )
    }
  )
)

#' @title General Regression Measures for Forecasting
#'
#' @name mlr_measures_forecast.regr
#' @format [R6::R6Class()] inheriting from [MeasureForecast].
#'
#' @export
#' @include MeasureForecast.R
MeasureForecastRegr = R6Class("MeasureForecastRegr",
  inherit = MeasureForecast,
  public = list(

    measure_regr = NULL,

    initialize = function(id = NULL, measure_regr) {
      self$measure_regr = as_measure(measure_regr)
      super$initialize(
        id = id %??% gsub("regr.", "forecast.regr.", measure_regr$id),
        range =   measure_regr$range,
        minimize = measure_regr$minimize,
        packages = "mlr3temporal"
      )
    }
  ),
  private = list(
    .score = function(prediction, ...) {
      mean(pmap_dbl(list(prediction$truth, prediction$response), self$measure_regr$fun))
    }
  )
)
