#' @title Petrol Forecast Task
#'
#' @name mlr_tasks_petrol
#' @format [R6::R6Class] inheriting from [TaskRegrForecast]
#'
#'
#' @section Construction:
#' ```
#' mlr_tasks$get("petrol")
#' tsk("petrol")
#' ```
#'
#' @section Meta Information:
#' `r rd_info(tsk("petrol"))`
#'
#' @template seealso_task
NULL

load_task_petrol = function(id = "petrol") {
  require_namespaces("fma")
  b = as_data_backend.forecast(fma::petrol)
  task = TaskRegrForecast$new(id, b, target = c("Chemicals", "Coal", "Petrol", "Vehicles"))
  b$hash = task$man = "mlr3temporal::mlr_tasks_petrol"
  task
}

#' @include aaa.R
tasks[["petrol"]] = load_task_petrol
