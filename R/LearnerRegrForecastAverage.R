#' @title Average Forecast Learner
#'
#' @name mlr_learners_regr.average
#'
#' @description
#' A model based on average values
#' Calls [base::mean] from package \CRANpkg{base}.
#'
#' @templateVar id forecast.average
#' @template learner
#'
#' @template seealso_learner
#' @export
#' @template example
LearnerRegrForecastAverage = R6::R6Class("LearnerRegrForecastAverage",
  inherit = LearnerForecast,

  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "forecast.average",
        predict_types = c("response"),
        packages = "base",
        man = "mlr3temporal::mlr_learners_regr.average",
        properties = c("univariate"),
        feature_types = c("logical", "integer", "numeric", "factor", "ordered")
      )
    },

    #' @description
    #' Returns forecasts after the last training instance.
    #'
    #' @param h (`numeric(1)`)\cr
    #'   Number of steps ahead to forecast. Default is 10.
    #'
    #' @param task ([Task]).
    #'
    #' @param new_data ([data.frame()])\cr
    #'   New data to predict on.
    #'
    #' @return [Prediction].
    forecast = function(h = 10, task, new_data = NULL) {
      response = as.data.table(rep(self$model, h))
      colnames(response) = task$target_names
      truth = copy(response)
      truth[, colnames(truth) := 0]
      p = PredictionForecast$new(task,
        response = response, truth = truth,
        row_ids = (self$date_span$end$row_id + 1):(self$date_span$end$row_id + h)
      )
    }
  ),

  private = list(
    .train = function(task) {
      span = range(task$date()[[task$date_col]])
      self$date_span = list(
        begin = list(time = span[1], row_id = task$row_ids[1]),
        end = list(time = span[2], row_id = task$row_ids[task$nrow])
      )
      x = task$data(cols = task$target_names)[[1L]]
      list("mean" = mean(x))
    },

    .predict = function(task) {
      response = rep(self$model$mean, length(task$row_ids))
      list(response = response)
    }
  )
)

#' @include aaa.R
learners[["forecast.average"]] = LearnerRegrForecastAverage
