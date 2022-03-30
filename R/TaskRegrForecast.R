#' @title Forecasting Task (Regression)
#'
#' @import data.table
#' @import mlr3
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [Task]/[TaskSupervised]/[TaskForecast].
#'
#' @description
#' This task specializes [Task] and [TaskSupervised] for forecasting regression problems.
#' The target column(s) are assumed to be numeric.
#' The `task_type` is set to `"regr"` `.
#'
#' @section Construction:
#' ```
#' t = TaskRegrForecast$new(id, backend, target, date_col)
#' ```
#'
#' * `id` :: `character(1)`\cr
#'   Identifier for the task.
#'
#' * `backend` :: [DataBackend]\cr
#'   Either a [DataBackendLong], a object of class `ts` or a `data.frame` with specified date column
#'
#'
#'     or any object which is convertible to a DataBackend with `as_data_backend()`.
#'   E.g., a object of class  `dts` will be converted to a [DataBackendLong].
#'
#' * `target` :: `character(n)`\cr
#'   Name of the target column(s).
#'
#' @section Fields:
#' All methods from [TaskSupervised] and [TaskForecast].
#'
#' @section Methods:
#' See [TaskSupervised] and [TaskForecast].
#'
#' @family Task
#' @seealso seealso_task
#' @export
TaskRegrForecast = R6::R6Class("TaskRegrForecast",
  inherit = TaskForecast,
  public = list(
    initialize = function(id, backend, target = "target", date_col = NULL) {
      # Initialize the task and properties
      super$initialize(id = id, backend = (backend), target = target, date_col = date_col)
      self$properties = union(self$properties, if (length(self$target_names) == 1L) "univariate" else "multivariate")
      assert_true(all(self$col_info[id %in% self$target_names]$type %in% c("numeric", "double", "integer")))
    }
  )
)
