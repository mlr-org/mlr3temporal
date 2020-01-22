


LearnerForecast = R6Class("LearnerRegr", inherit = Learner,
  public = list(
    initialize = function(id, param_set = ParamSet$new(), predict_types = "response",
      feature_types = character(), properties = character(), data_formats = "data.table",
      packages = character(), man = NA_character_) {
      super$initialize(id = id, task_type = "forecast", param_set = param_set, feature_types = feature_types,
        predict_types = predict_types, properties = properties, data_formats = data_formats, packages = packages, man = man)
    }
  )
)
