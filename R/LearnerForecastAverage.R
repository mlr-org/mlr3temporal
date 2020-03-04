#' @title Average Learner
#'
#' @name mlr_learners_regr.Average
#' @format [R6::R6Class] inheriting from [mlr3::LearnerRegr].
#'
#' @section Construction:
#' ```
#' LearnerForecastAverage$new()
#' ```
#'
#' @description
#' A LearnerRegrForecast for model based on average implemented in [forecast::average] in mlr3.
#'
#'
#' @template seealso_learner
#' @export
LearnerForecastAverage = R6::R6Class("LearnerForecastAverage", inherit = LearnerForecast,
  public = list(
    initialize = function() {
      super$initialize(
        id = "forecast.average",
        feature_types = c("logical", "integer", "numeric", "character", "factor", "ordered"),
        predict_types = c("response"),
        man = "mlr3::mlr_learners_forecast.average"
      )
    },

    train_internal = function(task) {
      span = range(task$date()[[task$date_col]])
      self$date_span =
        list(begin=list(time = span[1], row_id = task$row_ids[1]), end = list(time = span[2], row_id = task$row_ids[task$nrow]))
      self$date_frequency = time.frequency(task$date()[[task$date_col]])
      x = task$data(cols = task$target_names)[[1L]]
      mean(x)
    },

    predict_internal = function(task) {
      response = rep(self$model, task$nrow)
      PredictionForecast$new(task = task, response = response)
    }
  )
)
