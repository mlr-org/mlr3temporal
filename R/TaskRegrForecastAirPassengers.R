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

load_task_air_passengers = function(id = "airpassengers") {
  require_namespaces("datasets")
  b = as_data_backend.forecast(load_dataset("AirPassengers", "datasets"))
  task = TaskRegrForecast$new(id, b, target = "target")
  b$hash = task$man = "mlr3temporal::mlr_tasks_airpassengers"
  task
}

#' @include aaa.R
tasks[["airpassengers"]] = load_task_air_passengers
