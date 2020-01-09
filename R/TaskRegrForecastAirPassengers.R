#' @title AirPassengers Forecast Task
#'
#' @name mlr_tasks_airpassengers
#' @format [R6::R6Class] inheriting from [TaskRegrForecast].
#'
#' @section Construction:
#' ```
#' mlr_tasks$get("AirPassengers")
#' tsk("AirPassengers")
#' ```
#'
#' @description
#' A forecasting task for the [datasets::AirPassengers] data set.
#'
#' @template seealso_task
NULL

load_task_AirPassengers = function(id = "AirPassengers") {
  b = as_data_backend.forecast(load_dataset("AirPassengers", "datasets"))
  task = TaskRegrForecast$new(id, b, target = "target")
  b$hash = task$man = "mlr3::mlr_tasks_AirPassengers"
  task
}

#' @include mlr_tasks.R
mlr_tasks$add("AirPassengers", load_task_AirPassengers)
