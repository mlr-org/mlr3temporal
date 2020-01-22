TaskForecast = R6::R6Class("TaskForecast",
  inherit = TaskSupervised,
  public = list(
    initialize = function(id, backend, target, time) {
      assert_character(target)
      assert_string(time)
      super$initialize(id = id, task_type = "forecast", backend = backend, target = target)

      for (i in self$target_names){
        type = self$col_info[id == i]$type
        if (type %nin% c("integer", "numeric")) {
          stopf("Target column '%s' must be numeric", i)
        }
      }

      assert_choice(time, self$backend$colnames)

      # FIXME: time is the primary key; the primary key can't have a role
      # self$col_roles$order = time

    },

    truth = function(row_ids = NULL) {
      super$truth(row_ids)[[1L]]
    }
  ),

  active = list(

    timestamps = function(){
      self$backend$timestamps
    }

  )
)
