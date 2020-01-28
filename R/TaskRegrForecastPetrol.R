#' @title Petrol Multivariate Forecast Class
#'
#' @name mlr_tasks_petrol
#' @format [R6::R6Class] inheriting from [TaskRegrForecast]
#'
#' @section Construction:
#' ```
#' mlr_tasks$get("petrol")
#' tsk("petrol")
#' ```
#'
#' @description
#' A multivariate forecasting task for the [fma::petrol] data set.
#'
#' @template seealso_task
NULL

load_task_petrol = function(id = "petrol") {
  requireNamespace("fma")
  b = as_data_backend.forecast(fma::petrol)
  task = TaskRegrForecast$new(id, b, target = c("Chemicals", "Coal", "Petrol", "Vehicles"))
  b$hash = task$man = "mlr3forecasting::mlr_tasks_petrol"
  return(task)
}
