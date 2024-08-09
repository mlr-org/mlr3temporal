#' @title DataBackend for timeseries
#'
#' @description
#' [DataBackend] for \CRANpkg{data.table} which serves as an efficient in-memory data base.
#'
#' @template param_rows
#' @template param_cols
#' @template param_data_format
#' @template param_primary_key
#' @template param_na_rm
#'
#' @template seealso_databackend
#' @export
#' @examples
#' data = data.table::data.table(id = 1:5, x = runif(5), y = sample(letters[1:3], 5, replace = TRUE))
#' b = mlr3::DataBackendDataTable$new(data, primary_key = "id")
#' print(b)
#' b$head(2)
#' b$data(rows = 1:2, cols = "x")
#' b$distinct(rows = b$rownames, "y")
#' b$missings(rows = b$rownames, cols = names(data))
DataBackendTime = R6::R6Class("DataBackendTime",
  inherit = DataBackendDataTable,
  cloneable = FALSE,
  public = list(

    #' @field date_col (`character(1)`)\cr
    #' Name of the column containing the timestamps.
    date_col = NULL,
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' Note that `DataBackendTime` does not copy the input data, while `as_data_backend()` calls [data.table::copy()].
    #' `as_data_backend()` also takes care about casting to a `data.table()` and adds a primary key column if necessary.
    #'
    #' @param data ([data.table::data.table()])\cr
    #'   The input [data.table()].
    #'
    #' @param date_col (`character(1)`)\cr
    #'   Name of the column containing the timestamps.
    initialize = function(data, date_col, primary_key) {
#      assert_data_frame(data, ncols = 4L, col.names = "unique")
      setDT(data)
      super$initialize(data, primary_key)
      self$date_col = assert_choice(date_col, names(data))
      if (is.null(primary_key)) {
        setkeyv(data, c(date_col))
      } else {
        setkeyv(data, c(primary_key, date_col))
      }
    },

    #' @description
    #' Returns a slice of the data in the specified format.
    #' Currently, the only supported formats are `"data.table"` and `"Matrix"`.
    #' The rows must be addressed as vector of primary key values, columns must be referred to via column names.
    #' Queries for rows with no matching row id and queries for columns with no matching column name are silently ignored.
    #' Rows are guaranteed to be returned in the same order as `rows`, columns may be returned in an arbitrary order.
    #' Duplicated row ids result in duplicated rows, duplicated column names lead to an exception.
    #'
    #' @param roll (`logical(1)`)\cr
    #'  If `TRUE` (default), rows are rolled to the nearest existing row id if necessary.
    data = function(rows, cols, data_format = "data.table", roll = TRUE) {
      assert_atomic_vector(rows)
      assert_names(cols, type = "unique")
      assert_choice(data_format, self$data_formats)

      cols = intersect(cols, self$colnames)
      rows = keep_in_bounds(rows, 1L, max(private$.data[[self$primary_key]]))

      if (length(cols) == 0) {
        return(data.table()) # FIXME: Not sure what should be returned here. cols = "_not_existing_" check.
      }
      if (length(rows) != 0L) {
        dt = private$.data[rows, ..cols]
      } else {
        # keep all rows, subset later
        dt = private$.data[, ..cols]
      }
      return(dt)
    },

    #' @description
    #' Retrieve the first `n` rows.
    #'
    #' @param n (`integer(1)`)\cr
    #'   Number of rows.
    #'
    #' @return [data.table::data.table()] of the first `n` rows.
    head = function(n = 6L) {
      head(private$.data, n)
    },

    #' @description
    #' Returns a named list of vectors of distinct values for each column
    #' specified. If `na_rm` is `TRUE`, missing values are removed from the
    #' returned vectors of distinct values. Non-existing rows and columns are
    #' silently ignored.
    #'
    #' @return Named `list()` of distinct values.
    distinct = function(rows, cols, na_rm = TRUE) {
      assert_names(cols, type = "unique")
      assert_flag(na_rm)
      cols = intersect(cols, self$colnames)
      if (is.null(rows)) rows = self$rownames
      data = self$data(rows, cols)
      if (is.null(rows)) {
        set_names(lapply(cols, function(x) distinct_values(data[[x]], drop = FALSE, na_rm = na_rm)), cols)
      } else {
        lapply(data, distinct_values, drop = TRUE, na_rm = na_rm)
      }
    },

    #' @description
    #' Returns the number of missing values per column in the specified slice
    #' of data. Non-existing rows and columns are silently ignored.
    #'
    #' @return Total of missing values per column (named `numeric()`).
    missings = function(rows, cols) {
      assert_names(cols, type = "unique")
      data = self$data(rows, cols)
      map_int(data, function(x) sum(is.na(x)))
    }
  ),

  active = list(
    #' @field rownames (`integer()`)\cr
    #' Returns vector of all distinct row identifiers, i.e. the contents of the primary key column.
    rownames = function() {
      unique(private$.data[, self$primary_key, with = FALSE])[[1L]]
    },

    #' @field colnames (`character()`)\cr
    #' Returns vector of all column names, including the primary key column.
    colnames = function() {
      colnames(private$.data)
    },

    #' @field nrow (`integer(1)`)\cr
    #' Number of rows (observations).
    nrow = function() {
      nrow(private$.data)
    },

    #' @field ncol (`integer(1)`)\cr
    #' Number of columns (variables), including the primary key column.
    ncol = function() {
      ncol(private$.data)
    },

    #' @field key_cols (`character()`)\cr
    #' Returns vector of all column names that are part of the primary key.
    key_cols = function() {
      c(self$primary_key, self$date_col)
    }
  ),

  private = list(
    .calculate_hash = function() {
      digest(list(self$data, self$primary_key, self$value_col), algo = "xxhash64")
    }
  )
)

#' @rdname as_data_backend
#' @export
as_data_backend.dts = function(data, primary_key = NULL, target = NULL, ...) {
  if (ncol(data) == 2) {
    if (is.null(target)) {
      target = "target"
    }
    data$id = target
    cname = attr(data, "cname")
    cname$id = "id"
    setattr(data, "cname", cname)
  }
  id = NULL
  cname = attr(data, "cname")
  set(data, j = cname$time, value = as.POSIXct(data[[cname$time]]))
  if ("..row_id" %nin% names(data)) data[, "..row_id" := rowid(id)]
  DataBackendTime$new(data, primary_key = "..row_id", id_col = cname$id, date_col = cname$time)
}

#' @rdname as_data_backend
#' @export
as_data_backend.forecast = function(data, primary_key = NULL, ...) { # nolint
  require_namespaces("tsbox")
  as_data_backend(tsbox::ts_dts(data))
}
