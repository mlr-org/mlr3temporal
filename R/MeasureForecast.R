#' @title Forecast Measure
#'
#' @description
#' This measure specializes [Measure] for forecast problems:
#'
#' * `task_type` is set to `"forecast"`.
#' * Possible values for `predict_type` are `"response"`, `"se"` and `"distr"`.
#'
#' Predefined measures can be found in the [dictionary][mlr3misc::Dictionary] [mlr_measures].

#' @template param_id
#' @template param_range
#' @template param_minimize
#' @template param_average
#' @template param_aggregator
#' @template param_predict_type
#' @template param_measure_properties
#' @template param_predict_sets
#' @template param_task_properties
#' @template param_packages
#' @template param_man
#'
#' @template seealso_measure
#' @export
MeasureForecast = R6Class("MeasureForecast",
  inherit = Measure,
  cloneable = FALSE,

  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
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

#' @title Forecast Regression Measure
#'
#' @name mlr_measures_forecast.regr
#'
#' @template param_id
#'
#' @template seealso_measure
#' @export
MeasureForecastRegr = R6Class("MeasureForecastRegr",
  inherit = MeasureForecast,
  public = list(

    #' @field measure_regr ([Measure])\cr
    #'   Measure(s) to calculate.
    measure_regr = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param measure_regr ([Measure])\cr
    #'  Measure(s) to calculate.
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
