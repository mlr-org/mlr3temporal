#' @title Forecast Cross-Validation Resampling
#'
#' @name mlr_resamplings_forecast_cv
#'
#' @description
#' Splits data using a `folds`-folds (default: 10 folds) rolling window cross-validation.
#'
#' @templateVar id forecast_cv
#' @template resampling
#'
#' @section Parameters:
#' * `folds` (`integer(1)`)\cr
#'   Number of folds.
#' * window_size (`integer(1)`)\cr
#'   (Minimal) Size of the rolling window.
#' * horizon (`integer(1)`)\cr
#'   Forecasting horizon in the test sets.
#' * fixed_window (`logial(1)`)\cr
#'   Flag for fixed sized window. If FALSE an expanding window is used.
#'
#' @references
#' `r format_bib("bergmeir_2018")`
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

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ps(
        window_size = p_int(2L, tags = "required"),
        horizon = p_int(1L, tags = "required"),
        folds = p_int(1L, tags = "required"),
        fixed_window = p_lgl(tags = "required")
      )
      ps$values = list(window_size = 10L, horizon = 5L, folds = 10L, fixed_window = TRUE)

      super$initialize(id = "cv", param_set = ps, man = "mlr3temporal::mlr_resamplings_forecast_cv")
    }
  ),

  active = list(
    #' @template field_iters
    iters = function(rhs) {
      as.integer(self$param_set$values$folds)
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
