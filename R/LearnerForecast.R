LearnerForecast = R6Class("LearnerForecast", inherit = Learner,
  public = list(
    date_span = NULL,
    date_frequency = NULL,
    initialize = function(id, param_set = ParamSet$new(), predict_types = "response",
      feature_types = character(), properties = character(), data_formats = "data.table",
      packages = character(), man = NA_character_) {
      super$initialize(id = id, task_type = "forecast", param_set = param_set, feature_types = feature_types,
        predict_types = predict_types, properties = properties, data_formats = data_formats, packages = packages, man = man)
      },

    train = function(task, row_ids = NULL) {
      if(is.null(row_ids)){
        row_ids = task$row_ids
      }
      row_ids = sort(row_ids)
      super$train(task, row_ids)
      span = range(task$date(row_ids)[[task$date_col]])
      self$date_span =
        list(begin=list(time = span[1], row_id = head(row_ids,1)), end = list(time = span[2], row_id = tail(row_ids,1)))
      self$date_frequency = time.frequency(task$date(row_ids)[[task$date_col]])

      if(length(self$date_frequency)>1){
        warning("The timestamps are not equidistant.")
      }
    },

    predict = function(task, row_ids = NULL) {
      if(self$date_span$end$row_id == max(task$row_ids)){
        stop("No timesteps left for prediction")
      }
      if(is.null(row_ids)){
        row_ids = (self$date_span$end$row_id+1):min((self$date_span$end$row_id+10), max(task$row_ids))
      }
      row_ids = sort(row_ids)
      if(!test_set_equal(row_ids, self$date_span$end$row_id+(1:length(row_ids)))){
        warning("Predicted timesteps do not match the requested timesteps.")
      }
      super$predict(task, row_ids)
    }
  )
)
