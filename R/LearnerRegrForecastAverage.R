#' @title Average Learner
#'
#' @usage NULL
#' @name mlr_learners_regr.average
#' @format [R6::R6Class] inheriting from [mlr3forecasting::LearnerForecast].
#'
#' @section Construction:
#' ```
#' LearnerRegrForecastAverage$new()
#' ```
#'
#' @description
#' A LearnerRegrForecast model based on average values implemented in [base::mean()] in package \CRANpkg{base}.
#'
#'
#' @template seealso_learner
#' @export
LearnerRegrForecastAverage = R6::R6Class("LearnerRegrForecastAverage", inherit = LearnerForecast,
  public = list(
    initialize = function() {
      super$initialize(
        id = "forecast.average",
        predict_types = c("response"),
        packages = "base",
        man = "mlr3forecasting::mlr_learners_regr.average"
      )
    },

    train_internal = function(task) {
      span = range(task$date()[[task$date_col]])
      self$date_span =
        list(begin = list(time = span[1], row_id = task$row_ids[1]), end = list(time = span[2], row_id = task$row_ids[task$nrow]))
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
