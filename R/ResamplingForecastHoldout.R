#' @title Forecast Holdout Resampling
#'
#' @name mlr_resamplings_forecast_holdout
#'
#' @description
#' Splits data into a training set and a test set.
#' Parameter `ratio` determines the ratio of observation going into the training set (default: 2/3).
#'
#' @templateVar id forecast_cv
#' @template resampling
#'
#' @section Parameters:
#' * ratio (`numeric(1)`)\cr
#'   Ratio of observations to put into the training set.
#'
#' @template seealso_resampling
#' @export
#' @examples
#' # Create a task with 10 observations
#' task = mlr3::tsk("airpassengers")
#' task$filter(1:10)
#'
#' # Instantiate Resampling
#' rfho = mlr3::rsmp("forecast_holdout", ratio = 0.5)
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

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ps(
        ratio = p_dbl(0L, 1L, tags = "required")
      )
      ps$values = list(ratio = 2 / 3)

      super$initialize(id = "forecast_holdout", param_set = ps, man = "mlr3temporal::mlr_resamplings_forecast_holdout")
    },
    #' @template field_iters
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
