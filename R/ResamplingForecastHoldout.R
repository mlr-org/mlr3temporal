#' @title Forecast Holdout Resampling
#'
#' @usage NULL
#' @name mlr_resamplings_forecast_holdout
#' @format [R6::R6Class] inheriting from [Resampling].
#' @include ResamplingForecastHoldout.R
#'
#' @description
#' Splits data into a training set and a test set.
#' Parameter `ratio` determines the ratio of observation going into the training set (default: 2/3).
#'
#' @section Fields:
#' See [Resampling].
#'
#' @section Methods:
#' See [Resampling].
#'
#' @section Parameters:
#' * `ratio` :: `numeric(1)`\cr
#'   Ratio of observations to put into the training set.
#'
#'
#' @template seealso_resampling
#' @export
#' @examples
#' # Create a task with 10 observations
#' task = mlr3::tsk("airpassengers")
#' task$filter(1:10)
#'
#' # Instantiate Resampling
#' rfho = rsmp("forecast_holdout", ratio = 0.5)
#' rfho$instantiate(task)
#'
#' # Individual sets:
#' rfho$train_set(1)
#' rfho$test_set(1)
#' intersect(rfho$train_set(1), rfho$test_set(1))
#'
#' # Internal storage:
#' rfho$instance # simple list
ResamplingForecastHoldout = R6Class("ResamplingForecastHoldout",
  inherit = Resampling,
  public = list(
    initialize = function() {
      ps = ParamSet$new(list(
        ParamDbl$new("ratio", lower = 0, upper = 1, tags = "required")
      ))
      ps$values = list(ratio = 2 / 3)

      super$initialize(id = "forecast_holdout", param_set = ps, man = "mlr3temporal::mlr_resamplings_forecast_holdout")
    },
    iters = 1L
  ),
  private = list(
    .sample = function(ids, ...) {
      nr = round(length(ids) * self$param_set$values$ratio)
      ii = ids[1:nr]
      list(train = ii, test = setdiff(ids, ii))
    },
    .get_train = function(i) {
      self$instance$train
    },
    .get_test = function(i) {
      self$instance$test
    },
    .combine = function(instances) {
      list(train = do.call(c, map(instances, "train")), test = do.call(c, map(instances, "test")))
    }
  )
)

#' @include aaa.R
resamplings[["forecast_holdout"]] = ResamplingForecastHoldout
