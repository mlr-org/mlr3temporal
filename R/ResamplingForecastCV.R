#' @title Forecast Cross-Validation Resampling
#'
#' @usage NULL
#' @name mlr_resamplings_forecast_cv
#' @format [R6::R6Class] inheriting from [Resampling].
#' @include ResamplingForecastCV.R
#'
#' @description
#' Splits data using a `folds`-folds (default: 10 folds) rolling window cross-validation.
#'
#' @section Fields:
#' See [Resampling].
#'
#' @section Methods:
#' See [Resampling].
#'
#' @section Parameters:
#' * `folds` :: `integer(1)`\cr
#'   Number of folds.
#' * `window_size` :: `integer(1)`\cr
#'   (Minimal) Size of the rolling window.
#' * `horizon` :: `integer(1)`\cr
#'   Forecasting horizon in the test sets.
#' * `fixed_window` :: `logial(1)`\cr
#'   Flag for fixed sized window. If FALSE an expanding window is used.
#'
#' @references
#' \cite{mlr3}{bischl_2012}
#' paper:Ch. Bergmeir, R. J. Hyndman, B. Koo, A note on the validity of cross-validation for evaluating
#        autoregressive time series prediction, Computational Statistics and Data Analysis 120 (2018) 70–83.
#'
#' @template seealso_resampling
#' @export
#' @examples
#' # Create a task with 10 observations
#' task = mlr3::tsk("airpassengers")
#' task$filter(1:20)
#'
#' # Instantiate Resampling
#' rfho = mlr3::rsmp("forecast_cv", folds = 3, fixed_window = FALSE)
#' rfho$instantiate(task)
#'
#' # Individual sets:
#' rfho$train_set(1)
#' rfho$test_set(1)
#' intersect(rfho$train_set(1), rfho$test_set(1))
#'
#' # Internal storage:
#' rfho$instance #  list
ResamplingForecastCV = R6Class("ResamplingForecastCV",
  inherit = Resampling,
  public = list(
    initialize = function() {
      ps = ParamSet$new(list(
        ParamInt$new("window_size", lower = 2L, tags = "required"),
        ParamInt$new("horizon", lower = 1L, tags = "required"),
        ParamInt$new("folds", lower = 1L, tags = "required"),
        ParamLgl$new("fixed_window", tags = "required")
      ))
      ps$values = list(window_size = 10L, horizon = 5L, folds = 10L, fixed_window = TRUE)

      super$initialize(id = "cv", param_set = ps, man = "mlr3temporal::mlr_resamplings_forecast_cv")
    }
  ),
  active = list(
    iters = function(rhs) {
      asInteger(self$param_set$values$folds)
    }
  ),
  private = list(
    .sample = function(ids, ...) {
      ids = sort(ids)
      if (self$param_set$values$fixed_window) {
        train_start = ids[ids <= (max(ids) - self$param_set$values$horizon - self$param_set$values$window_size + 1)]
        s = sample(train_start, self$param_set$values$folds)
        s = sort(s)
        train_ids = lapply(
          s,
          function(x) x:(x + self$param_set$values$window_size - 1)
        )
      } else {
        train_end = ids[ids <= (max(ids) - self$param_set$values$horizon) & ids >= self$param_set$values$window_size]
        s = sample(train_end, self$param_set$values$folds)
        s = sort(s)
        train_ids = lapply(s, function(x) min(ids):x)
      }
      test_ids = lapply(
        train_ids,
        function(x) (max(x) + 1):(max(x) + self$param_set$values$horizon)
      )

      list(train = train_ids, test = test_ids)
    },
    .get_train = function(i) {
      self$instance$train[[i]]
    },
    .get_test = function(i) {
      self$instance$test[[i]]
    },
    .combine = function(instances) {
      rbindlist(instances, use.names = TRUE)
    },
    deep_clone = function(name, value) {
      if (name == "instance") copy(value) else value
    }
  )
)

#' @include aaa.R
resamplings[["forecast_cv"]] = ResamplingForecastCV
