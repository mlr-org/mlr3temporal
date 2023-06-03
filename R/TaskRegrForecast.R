#' @title Forecasting Regression Task
#'
#' @description
#' This task specializes [Task] and [TaskSupervised] for forecasting regression problems.
#' The target column(s) are assumed to be numeric.
#' The `task_type` is set to `"regr"` `.
#'
#' @template param_id
#' @template param_backend
#'
#' @template seealso_task
#' @export
TaskRegrForecast = R6::R6Class("TaskRegrForecast",
  inherit = TaskForecast,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @template param_target
    #'
    #' @param date_col (`character(1)`)\cr
    #'   Name of the date column, only required if backend is a `data.frame`.
    initialize = function(id, backend, target = "target", date_col = NULL) {
      super$initialize(id = id, backend = (backend), target = target, date_col = date_col)
      self$properties = union(self$properties, if (length(self$target_names) == 1L) "univariate" else "multivariate")
      assert_true(all(self$col_info[id %in% self$target_names]$type %in% c("numeric", "double", "integer")))
    }
  )
)
