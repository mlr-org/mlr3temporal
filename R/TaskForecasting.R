TaskForecast = R6::R6Class("TaskForecast",
  inherit = TaskSupervised,
  public = list(
    initialize = function(id, backend, target, time) {
      assert_string(target)
      super$initialize(id = id, task_type = "forecast", backend = backend, target = target)

      type = self$col_info[id == target]$type
      if (type %nin% c("integer", "numeric")) {
        stopf("Target column '%s' must be numeric", target)
      }

      assert_choice(time, self$backend$colnames)
      self$col_roles$order = time
    },

    truth = function(row_ids = NULL) {
      super$truth(row_ids)[[1L]]
    }
  )
)
