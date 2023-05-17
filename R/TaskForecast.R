#' @title Forecasting Task
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [Task]/[TaskSupervised].
#'
#' @description
#' Introduces a new Forecasting Task that inherits from [TaskSupervised] which can be used to forecast time series.
#' This is an abstract class, which should not be instantiated.
#' Use the subclass [TaskRegrForecast] instead.
#' The `task_type` is set to `"forecast"`.
#'
#' Note, that in case the input is a `data.table' or `data.frame`, `mlr3temporal` expects a "wide"
#' data.frame as input. The `tsbox::to_wide()` function can help casting time-series to this format.
#'
#'
#' @section Construction:
#' ```
#' t = TaskForecast$new(id, backend, target, date_col)
#' ```
#'
#' * `id` :: `character(1)`\cr
#'   Identifier for the task.
#'
#' * `backend` :: [DataBackend]\cr
#'   Either a [DataBackendLong], an object of class `ts` or a `data.frame` with specified date column
#'   or any object which is convertible to a DataBackendLong with `as_data_backend()`.
#'   E.g., a object of class  `dts` (from package tsbox) will be converted to a [DataBackendLong].
#'
#' * `target` :: `character(n)`\cr
#'   Name of the target column(s).
#' * `date_col` :: `character(1)`\cr
#'   Name of the date column, only required if backend is a `data.frame`.
#'
#' @section Fields:
#' All methods inherited from [TaskSupervised], and additionally:
#' * `date_col` :: `character(1)`\cr
#'   Name of the date column.
#
#' @section Methods:
#' See [TaskSupervised], additionally:
#' * `date(row_ids = NULL)`  :: `data.table`\cr
#'   (`integer()` | `character()`) -> named `list()`\cr
#'   Returns the `date` column.
#'
#' @family Task
#' @seealso seealso_task
#' @export
TaskForecast = R6::R6Class("TaskForecast",
  inherit = TaskSupervised,
  public = list(
    initialize = function(id, backend, target, date_col = NULL) {
      assert_character(target)
      if (inherits(backend, "data.frame")) {
        assert_subset(date_col, colnames(backend))
        backend = df_to_backend(backend, target, date_col)
      }
      if (!inherits(backend, "DataBackend")) {
        backend = as_data_backend(tsbox::ts_dts(backend), target = target)
      }
      super$initialize(id = id, task_type = "forecast", backend = backend, target = target)
      private$.col_roles$feature = setdiff(private$.col_roles$feature, self$date_col)
      self$col_roles$date_col = date_col %??% "time"
    },

    truth = function(row_ids = NULL) {
      if (c("multivariate") %in% self$properties) {
        self$data(row_ids, cols = self$target_names)
      } else {
        super$truth(row_ids)[[1L]]
      }
    },

    data = function(rows = NULL, cols = NULL, data_format = "data.table") {
      data = super$data(rows, cols, data_format)
      # Order data by date: FIXME: Should this happen here or in the backend.
      date = self$date(rows)
      assert_true(nrow(data) == nrow(data))
      data[order(date), ]
    },

    date = function(row_ids = NULL) {
      rows = row_ids %??% self$row_roles$use
      self$backend$data(rows, self$date_col)
    }
  ),

  active = list(
    date_col = function() {
      self$backend$date_col
    }
  )
)
