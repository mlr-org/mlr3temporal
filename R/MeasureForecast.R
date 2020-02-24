#' @title Forecast Regression Measure
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [mlr3::Measure].
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
MeasureForecast = R6Class("MeasureForecast", inherit = Measure, cloneable = FALSE,
  public = list(
    initialize = function(id, range, minimize = NA, average = "macro", aggregator = NULL, properties = character(), predict_type = "response",
                          predict_sets = "test", task_properties = character(), packages = character(), man = NA_character_) {
      super$initialize(id, task_type = "forecast", range = range, minimize = minimize, average = average, aggregator = aggregator,
                       properties = properties, predict_type = predict_type, predict_sets = predict_sets,
                       task_properties = task_properties, packages = packages, man = man)
    }
  )
)
