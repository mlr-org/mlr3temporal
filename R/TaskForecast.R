TaskForecast = R6::R6Class("TaskForecast",
  inherit = TaskSupervised,
  public = list(
    initialize = function(id, backend, target) {
      assert_character(target)
      if (!inherits(backend, "DataBackend"))
        backend = as_data_backend(ts_dts(backend))
      super$initialize(id = id, task_type = "forecast", backend = backend, target = target)
      private$.col_roles$feature = setdiff(private$.col_roles$feature, self$date_col)
    },
    truth = function(row_ids = NULL) {
      super$truth(row_ids)[[1L]]
    },
    data = function(rows = NULL, cols = NULL, data_format = "data.table") {
      data = super$data(rows, cols, data_format)
      # Order data by date: FIXME: Should this happen here or in the backend.
      date = self$date(rows)
      assert_true(nrow(data) == nrow(data))
      data[order(date), ]
    },
    date = function(row_ids = NULL) {
      rows = row_ids %??% self$backend$rownames
      self$backend$data(rows, self$date_col)
    }
  ),
  active = list(
    date_col = function() {
      self$backend$date_col
    }
  )
)
