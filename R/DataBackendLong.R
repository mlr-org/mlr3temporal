DataBackendLong = R6::R6Class("DataBackendLong",
  inherit = mlr3::DataBackend,
  cloneable = FALSE,

  public = list(
    id_col = NULL,
    value_col = NULL,

    initialize = function(data, primary_key, id_col) {
      assert_data_frame(data, ncol = 3L, col.names = "unique")
      setDT(data)
      super$initialize(data, primary_key, data_formats = "data.table")

      self$id_col = assert_choice(id_col, names(data))
      self$value_col = setdiff(colnames(data), c(primary_key, id_col))
      setkeyv(data, c(primary_key, id_col))
    },

    data = function(rows, cols, data_format = "data.table", roll = TRUE) {
      assert_atomic_vector(rows)
      assert_names(cols, type = "unique")
      assert_choice(data_format, self$data_formats)
      cols = intersect(cols, self$colnames)

      data = private$.data[CJ(rows, setdiff(cols, self$primary_key)), roll = roll]
      if (nrow(data) == 0L) {
        if (setequal("time", cols)) {
          private$.data[list(rows), self$primary_key, on = self$primary_key, with = FALSE][[1]]
        } else {
          cbind(
            as.data.table(named_list(setdiff(cols, self$primary_key), vector(typeof(private$.data$value)))))
          # FIXME ....
        }
      } else {
        dcast(data, formulate(self$primary_key, self$id_col))
      }
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

      tab = private$.data[CJ(rows, cols), list(N = uniqueN(self$value_col, na.rm = na_rm)), by = c(self$id_col)]
      set_names(tab[["N"]], tab[[self$id_col]])
    },

    missings = function(rows, cols) {
      assert_atomic_vector(rows)
      assert_names(cols, type = "unique")
      cols = intersect(cols, self$colnames)

      private$.data[CJ(rows, cols), list(N = sum(is.na(self$value_col))), by = c(self$id_col)]
      set_names(tab[["N"]], tab[[self$id_col]])
    }
  ),

  active = list(
    rownames = function() {
      unique(private$.data[, self$primary_key, with = FALSE])[[1L]]
    },

    colnames = function() {
      c(self$primary_key, unique(private$.data[, self$id_col, with = FALSE])[[1L]])
    },

    nrow = function() {
      uniqueN(private$.data, by = self$primary_key)
    },

    ncol = function() {
      uniqueN(private$.data, by = self$id_col) + 1L
    }
  ),

  private = list(
    .calculate_hash = function() {
      digest(list(self$data, self$primary_key, self$value_col), algo = "xxhash64")
    }
  )
)

#' @export
as_data_backend.dts = function(data) {
  cname = attr(data, "cname")
  set(data, j = cname$time, value = as.IDate(data[[cname$time]]))
  DataBackendLong$new(data, primary_key = cname$time, id_col = cname$id)
}

#' @export
as_data_backend.forecast = function(data) {
  require_namespaces("tsbox")
  as_data_backend(tsbox::ts_dts(data))
}
