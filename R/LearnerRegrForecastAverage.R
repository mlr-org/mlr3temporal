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
#' @section Methods:
#' See [LearnerForecast], additionally:
#' * `forecast(h = 10, task, new_data)`  :: `data.table`\cr
#' Returns forecasts after the last training instance.
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
        man = "mlr3forecasting::mlr_learners_regr.average",
        properties = c("univariate"),

      )
    },


    forecast = function(h = 10, task, new_data = NULL) {
      response = as.data.table(rep(self$model, h))
      colnames(response) = task$target_names
      truth = copy(response)
      truth[,colnames(truth) := 0]
      p = PredictionForecast$new(task, response = response, truth = truth,
        row_ids = (self$date_span$end$row_id+1):(self$date_span$end$row_id + h) )
    }
  ), 

  private = list(
    .train = function(task) {
      span = range(task$date()[[task$date_col]])
      self$date_span =
        list(begin = list(time = span[1], row_id = task$row_ids[1]), end = list(time = span[2], row_id = task$row_ids[task$nrow]))
      x = task$data(cols = task$target_names)[[1L]]
      mean(x)
    },

    .predict = function(task) {
      response = rep(self$model, task$nrow)
      PredictionForecast$new(task = task, response = response)
    }
  )
)
