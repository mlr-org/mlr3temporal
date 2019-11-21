LearnerForeCastAverage = R6Class("LearnerForeCastAverage", inherit = LearnerForecast,
  public = list(
    initialize = function() {
      super$initialize(
        id = "regr.featureless",
        feature_types = c("logical", "integer", "numeric", "character", "factor", "ordered"),
        predict_types = c("response"),
        man = "mlr3::mlr_learners_forecast.average"
      )
    },

    train_internal = function(task) {
      x = task$data(cols = task$target_names)[[1L]]
      mean(x)
    },

    predict_internal = function(task) {
      response = rep(self$model, task$nrow)
      PredictionForecast$new(task = task, response = response)
    }
  )
)

#' @include mlr_learners.R
mlr_learners$add("forecast.average", LearnerForeCastAverage)
