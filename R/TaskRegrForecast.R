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
#' t = TaskRegrForecast$new(id, backend, target, time.col)
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
#' * `time.col` :: `character(1)`\cr
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
  inherit = TaskForecast,
  public = list(

    initialize = function(id, backend, target="target", time.col="time") {

      assert_multi_class (backend,c("data.frame", "ts", "DataBackend"))

      # melts data.frames into long format and coerces to an object of class dts
      # as.numeric on the value columns removes possible unnecessary classes
      if (is.data.frame(backend)) {
        setDT(backend)
        assert_subset(time.col,names(backend))
        assert_subset(target,names(backend))
        assert_data_table( backend[, setdiff(names(backend),time.col), with = FALSE], types = "numeric")
        backend = (melt(backend, id.vars = time.col, variable.factor = FALSE))
        backend$value = as.numeric(backend$value)
        backend[[time.col]] = as.POSIXct(backend[[time.col]])
        backend = ts_dts(backend)
      } else if ("ts" %in% class(backend)) {
        backend = ts_dts(backend)
        assert_numeric(backend$value)
        if(ncol(backend)==2) {
          backend$id = target
          attr(backend, "cname")$id = "id"
        }
      }
      # Initialize the task and properties
      super$initialize(id = id, backend = (backend), target = target, time = time.col)
      for (i in self$target_names){
        type = self$col_info[id == i]$type
        if (type %nin% c("integer", "numeric")) {
          stopf("Target column '%s' must be numeric", i)
        }
      }
      self$properties = union(self$properties, if (length(self$target_names) == 1L) "univariate" else "multivariate")
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
