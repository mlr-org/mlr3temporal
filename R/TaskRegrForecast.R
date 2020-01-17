#' @title Forecast Regression Task
#'
#' @import data.table
#' @import mlr3
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [Task]/[TaskSupervised]/[TaskRegr].
#'
#' @description
#' This task specializes [Task] and [TaskSupervised] for forecasting regression problems.
#' The target column is assumed to be numeric.
#' The `task_type` is set to `"regr"` `.

#'
#' @section Construction:
#' ```
#' t = TaskRegrForecast$new(id, backend, target, date.col)
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
#' * `date.col` :: `character(1)`\cr
#'   Name of the date column. Not needed if backend is a timeseries
#'
#' @section Fields:
#' All methods from [TaskSupervised] and [TaskRegr], and additionally:
#'

#' @section Methods:
#' See [TaskSupervised] and [TaskRegr].
#'
#' @family Task
#' @seealso seealso_task
#' @export
TaskRegrForecast <- R6::R6Class("TaskRegrForecast",
  inherit = TaskRegr,
  public = list(

    initialize = function(id, backend, target, date.col = NULL) {
      assert_string(date.col, null.ok = TRUE)
      # FIXME: A comment here would be nice
      # FIXME: Add asserts for target in data etc.
      if (!is.null(date.col) && is.data.frame(backend)) {
        setDT(backend)
        backend = (melt(backend, id.vars = date.col, variable.factor = FALSE))
        backend$value = as.numeric(backend$value)
        backend[[date.col]] = as.POSIXct(backend[[date.col]])
        backend = ts_dts(backend)
      } else if ("ts" %in% class(backend)) {
        backend = ts_dts(backend)
        if(ncol(backend)==2) {
          backend$id = target
          attr(backend, "cname")$id = "id"
        }
      }
      # Initialize the task and properties
      super$initialize(id = id, backend = (backend), target = target)
      for (i in self$target_names){
        type = self$col_info[id == i]$type
        if (type %nin% c("integer", "numeric")) {
          stopf("Target column '%s' must be numeric", i)
        }
      }
      self$properties = union(self$properties, if (length(self$target_names) == 1L) "univariate" else "multivariate")
    },
    truth = function(row_ids = NULL) {
      super$truth(row_ids)[[1L]]
    },
    time_col = function(row_ids = NULL){
      if (is.null(row_ids)) {
        self$backend$data(self$backend$rownames, self$backend$colnames)[[self$backend$primary_key]]
       }else {
        self$backend$data(assert_integerish(row_ids), self$backend$colnames)[[self$backend$primary_key]]
      }
    }
  ),
)
