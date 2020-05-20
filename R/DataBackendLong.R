#' @title DataBackend
#'
#' @usage NULL
#' @format  [R6::R6Class] inheriting from [mlr3::DataBackend]
#'
#' @description
#' DataBackend for timeseries in long-format
#'
#' Data Backends provide a layer of abstraction for various data storage systems.
#' It is not recommended to work directly with the DataBackend.
#' Instead, all data access is handled transparently via the [Task].
#'
#' To connect to out-of-memory database management systems such as SQL servers, see \CRANpkg{mlr3db}.
#'
#' The required set of fields and methods to implement a custom DataBackend is listed in the respective sections.
#' See [DataBackendDataTable] or [DataBackendMatrix] for exemplary implementations of the interface.
#'
#' @section Construction:
#' Note: This object is typically constructed via a derived classes, e.g. [DataBackendDataTable] or [DataBackendMatrix],
#' or via the S3 method [as_data_backend()].
#'
#' ```
#' DataBackend$new(data, primary_key = NULL, data_formats = "data.table")
#' ```
#'
#' * `data` :: `any`\cr
#'   The format of the input data depends on the specialization.
#'   E.g., [DataBackendDataTable] expects a [data.table::data.table()] and [DataBackendMatrix] expects a [Matrix::Matrix()]
#'   constructed with the \CRANpkg{Matrix} package.
#'
#' * `primary_key` :: `character(1)`\cr
#'   Each DataBackend needs a way to address rows, which is done via a column of unique values, referenced here by `primary_key`.
#'   The use of this variable may differ between backends.
#'
#' * data_formats (`character()`)\cr
#'   Set of supported formats, e.g. `"data.table"` or `"Matrix"`.
#'
#' @section Fields:
#' * `nrow` :: `integer(1)`\cr
#'   Number of rows (observations).
#'
#' * `ncol` :: `integer(1)`\cr
#'   Number of columns (variables), including the primary key column.
#'
#' * `colnames` :: `character()`\cr
#'   Returns vector of all column names, including the primary key column.
#'
#' * `rownames` :: (`integer()` | `character()`)\cr
#'   Returns vector of all distinct row identifiers, i.e. the primary key column.
#'
#' * `hash` :: `character(1)`\cr
#'   Returns a unique hash for this backend. This hash is cached.
#'
#' * `data_formats` :: `character()`\cr
#'   Vector of supported data formats.
#'   A specific format can be chosen in the `$data()` method.
#'
#' @section Methods:
#' * `data(rows = NULL, cols = NULL, format = "data.table")`\cr
#'   (`integer()` | `character()`, `character()`) -> `any`\cr
#'   Returns a slice of the data in the specified format.
#'   Currently, the only supported formats are `"data.table"` and `"Matrix"`.
#'   The rows must be addressed as vector of primary key values, columns must be referred to via column names.
#'   Queries for rows with no matching row id and queries for columns with no matching column name are silently ignored.
#'   Rows are guaranteed to be returned in the same order as `rows`, columns may be returned in an arbitrary order.
#'   Duplicated row ids result in duplicated rows, duplicated column names lead to an exception.
#'
#' * `distinct(rows, cols, na_rm = TRUE)`\cr
#'   (`integer()` | `character()`, `character()`, `logical(1)`) -> named `list()`\cr
#'   Returns a named list of vectors of distinct values for each column specified.
#'   If `na_rm` is `TRUE`, missing values are removed from the returned vectors of distinct values.
#'   Non-existing rows and columns are silently ignored.
#'
#'   If `rows` is `NULL`, all possible distinct values will be returned, even if the value is not present in the data.
#'   This affects factor-like variables with empty levels, if supported by the backend.
#'
#' * `head(n = 6)`\cr
#'   `integer(1)` -> [data.table::data.table()]\cr
#'   Returns the first up-to `n` rows of the data as [data.table::data.table()].
#'
#' * `missings(rows, cols)`\cr
#'   (`integer()` | `character()`, `character()`) -> named `integer()`\cr
#'   Returns the number of missing values per column in the specified slice of data.
#'   Non-existing rows and columns are silently ignored.
#'
#' @family DataBackend
#' @seealso
#' Extension Packages: \CRANpkg{mlr3db}
#' @export
# @examples
# data = data.table::data.table(id = 1:5, x = runif(5), y = sample(letters[1:3], 5, replace = TRUE))
#
# b = DataBackendDataTable$new(data, primary_key = "id")
# print(b)
# b$head(2)
# b$data(rows = 1:2, cols = "x")
# b$distinct(rows = b$rownames, "y")
# b$missings(rows = b$rownames, cols = names(data))
DataBackendLong = R6::R6Class("DataBackendLong",

  inherit = mlr3::DataBackend,
  cloneable = FALSE,

  public = list(
    id_col = NULL,
    value_col = NULL,
    date_col = NULL,

    initialize = function(data, primary_key, id_col, date_col) {
      assert_data_frame(data, ncol = 4L, col.names = "unique")
      setDT(data)
      super$initialize(data, primary_key, data_formats = "data.table")

      self$id_col = assert_choice(id_col, names(data))
      self$date_col = assert_choice(date_col, names(data))
      self$value_col = setdiff(colnames(data), c(primary_key, id_col, date_col))
      setkeyv(data, c(primary_key, id_col))
    },

    data = function(rows, cols, data_format = "data.table", roll = TRUE) {
      assert_atomic_vector(rows)
      assert_names(cols, type = "unique")
      assert_choice(data_format, self$data_formats)

      cols = intersect(cols, self$colnames)
      rows = keep_in_bounds(rows, 1L, max(private$.data[[self$primary_key]]))

      if (length(cols) == 0)
        return(data.table()) # FIXME: Not sure what should be returned here. cols = "_not_existing_" check.
      if (!all(cols %in% self$key_cols))
        subset_cols = setdiff(cols, self$key_cols) # for dcasting id_col
      else
        subset_cols = cols # case we only want primary key or date
      # FIXME: This is not very efficient, but seems reasonably robust


      if (length(rows) != 0L)
        dt = private$.data[CJ(rows, subset_cols), roll = roll]
      else # else: keep all rows, subset later
        dt = private$.data[CJ(private$.data[[self$primary_key]], subset_cols), roll = roll]
      dt = dcast(dt, formulate(paste0(c(self$key_cols), collapse = "+"), self$id_col), fun.aggregate = identity, fill = NA)
      dt = dt[list(rows), cols, with = FALSE, on = self$primary_key, nomatch = 0L]
      return(dt)
    },

    head = function(n = 6L) {
      rn = head(self$rownames, n)
      cn = self$colnames
      self$data(rn, cn)
    },

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

    missings = function(rows, cols) {
      assert_names(cols, type = "unique")
      data = self$data(rows, cols)
      map_int(data, function(x) sum(is.na(x)))
    }
  ),

  active = list(
    rownames = function() {
      unique(private$.data[, self$primary_key, with = FALSE])[[1L]]
    },

    colnames = function() {
      c(self$primary_key, self$date_col, unique(private$.data[, self$id_col, with = FALSE])[[1L]])
    },

    nrow = function() {
      uniqueN(private$.data, by = self$primary_key)
    },

    ncol = function() {
      uniqueN(private$.data, by = self$id_col) + 2L
    },
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

#' @export
as_data_backend.dts = function(data, target = NULL) {
  if(ncol(data) == 2){
    if(is.null(target)){
      target = "target"
    }
    data$id = target
    cname = attr(data,"cname")
    cname$id = "id"
    setattr(data, "cname", cname)
  }
  id = NULL
  cname = attr(data, "cname")
  set(data, j = cname$time, value = as.POSIXct(data[[cname$time]]))
  if ("..row_id" %nin% names(data)) data[, "..row_id" := rowid(id)]
  DataBackendLong$new(data, primary_key = "..row_id", id_col = cname$id, date_col = cname$time)
}

#' @export
as_data_backend.forecast = function(data) {
  require_namespaces("tsbox")
  as_data_backend(tsbox::ts_dts(data))
}
