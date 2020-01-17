#' @title Petrol Multivariate Forecast Class
#'
#' @name mlr_tasks_petrol
#' @format [R6::R6Class] inheriting from [TaskRegrForecastMultiv]
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

load_task_petrol = function(id = "petrol"){
  b = as_data_backend.forecast(load_dataset("petrol","fma"))
  b$hash = "_mlr3_tasks_petrol_"
  TaskRegrForecastMultiv$new(id, b, target = c("Chemicals","Coal","Petrol","Vehicles"))
}