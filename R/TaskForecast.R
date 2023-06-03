#' @title Forecasting Task
#'
#' @description
#' This is the abstract base class for [TaskRegrForecast].
#' It extends [TaskSupervised] with methods to handle forecasting tasks.
#'
#' Note, that in case the input is a `data.table' or `data.frame`, `mlr3temporal` expects a "wide"
#' data.frame as input. The `tsbox::to_wide()` function can help casting time-series to this format.
#'
#' @template param_backend
#' @template param_cols
#' @template param_data_format
#' @template param_id
#' @template param_rows
#'
#' @template seealso_task
#' @export
TaskForecast = R6::R6Class("TaskForecast",
  inherit = TaskSupervised,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @template param_target
    #'
    #' @param date_col (`character(1)`)\cr
    #'   Name of the date column, only required if backend is a `data.frame`.
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

    #' @description
    #' True response for specified `row_ids`. Format depends on the task type.
    #' Defaults to all rows with role "use".
    #' @return `numeric()`.
    truth = function(rows = NULL) {
      if (c("multivariate") %in% self$properties) {
        self$data(rows, cols = self$target_names)
      } else {
        super$truth(rows)[[1L]]
      }
    },

    #' @description
    #' Returns a slice of the data from the [DataBackend] in the data format specified by `data_format`.
    #' Rows default to observations with role `"use"`, and
    #' columns default to features with roles `"target"` or `"feature"`.
    #' If `rows` or `cols` are specified which do not exist in the [DataBackend],
    #' an exception is raised.
    #'
    #' Rows and columns are returned in the order specified via the arguments `rows` and `cols`.
    #' If `rows` is `NULL`, rows are returned in the order of `task$row_ids`.
    #' If `cols` is `NULL`, the column order defaults to
    #' `c(task$target_names, task$feature_names)`.
    #' Note that it is recommended to **not** rely on the order of columns, and instead always
    #' address columns with their respective column name.
    #'
    #' @param ordered (`logical(1)`)\cr
    #'   If `TRUE`, data is ordered according to the columns with column role `"order"`.
    #'
    #' @return Depending on the [DataBackend], but usually a [data.table::data.table()].
    data = function(rows = NULL, cols = NULL, data_format = "data.table") {
      data = super$data(rows, cols, data_format)
      # Order data by date: FIXME: Should this happen here or in the backend.
      date = self$date(rows)
      assert_true(nrow(data) == nrow(data))
      data[order(date), ]
    },

    #' @description
    #' Returns the `date` column.
    date = function(rows = NULL) {
      rows = rows %??% self$row_roles$use
      self$backend$data(rows, self$date_col)
    }
  ),

  active = list(
    #' @field date_col (`character(1)`)\cr
    #' Returns the date column.
    date_col = function() {
      self$backend$date_col
    }
  )
)
