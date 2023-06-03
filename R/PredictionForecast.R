#' @title Prediction Object for Forecasting
#'
#' @include PredictionForecast.R
#'
#' @description
#' This object wraps the predictions returned by a learner of class [LearnerForecast], i.e.
#' the predicted response and standard error.
#'
#' @template seealso_prediction
#' @export
#' @examples
#' task = mlr3::tsk("airpassengers")
#' learner = mlr3::lrn("forecast.average")
#' learner$train(task, 1:30)
#' p = learner$predict(task, 31:50)
#' p$predict_types
#' head(data.table::as.data.table(p))
PredictionForecast = R6::R6Class("PredictionForecast",
  inherit = Prediction,
  cloneable = FALSE,

  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param task ([TaskRegr])\cr
    #'   Task, used to extract defaults for `row_ids` and `truth`.
    #'
    #' @param row_ids (`integer()`)\cr
    #'   Row ids of the predicted observations, i.e. the row ids of the test set.
    #'
    #' @param truth (`numeric()`)\cr
    #'   True (observed) response.
    #'
    #' @param response (`numeric()`)\cr
    #'   Vector of numeric response values.
    #'   One element for each observation in the test set.
    #'
    #' @param se (`numeric()`)\cr
    #'   Numeric vector of predicted standard errors.
    #'   One element for each observation in the test set.
    #'
    #' @param distr (`VectorDistribution`)\cr
    #'   `VectorDistribution` from package distr6 (in repository \url{https://raphaels1.r-universe.dev}).
    #'   Each individual distribution in the vector represents the random variable 'survival time'
    #'   for an individual observation.
    #'
    #' @param check (`logical(1)`)\cr
    #'   If `TRUE`, performs some argument checks and predict type conversions.
    initialize = function(task = NULL,
                          row_ids = task$row_ids,
                          truth = task$truth(),
                          response = NULL,
                          se = NULL,
                          distr = NULL,
                          check = TRUE) {

      pdata = list(row_ids = row_ids, truth = truth, response = response, se = se, distr = distr)
      pdata = discard(pdata, is.null)
      class(pdata) = c("PredictionDataForecast", "PredictionData")

      if (check) {
        pdata = check_prediction_data(pdata)
      }

      self$task_type = "forecast"
      self$predict_types = c("response", "se", "distr")[c(!is.null(response), !is.null(se), !is.null(distr))]
      self$man = "mlr3temporal::PredictionForecast"
      self$data = pdata
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function(...) {
      data = as.data.table(self)
      if (!nrow(data)) {
        catf("%s for 0 observations", format(self))
      } else {
        catf("%s for %i observations:", format(self), nrow(data))
        print(data, nrows = 10L, topn = 3L, class = FALSE, row.names = FALSE, print.keys = FALSE)
      }
    },

    #' @description
    #' Access to the stored predicted response.
    #' @param level (`numeric(1)`)\cr
    #'   Confidence level in percent.
    conf_int = function(level = 95) {
      assert_integerish(level, lower = 0, upper = 100)
      lapply(colnames(self$response), function(x) {
        setnames(
          data.table(
            upper = self$response[, ..x] + se_to_ci(se = self$se[, ..x], level),
            lower = self$response[, ..x] - se_to_ci(se = self$se[, ..x], level)
          ),
          c(
            paste0(eval(x), "_upper_", eval(level)),
            paste0(eval(x), "_lower_", eval(level))
          )
        )
      })
    }
  ),

  active = list(
    #' @field response (`numeric()`)\cr
    #' Access the stored predicted response.
    response = function() {
      self$data$response %??% rep(NA_real_, length(self$data$tab$truth$row_id))
    },

    #' @field se (`numeric()`)\cr
    #' Access the stored standard error.
    se = function() {
      self$data$se %??% rep(NA_real_, length(self$data$tab$truth$row_id))
    },

    #' @field missing (`integer()`)\cr
    #'   Returns `row_ids` for which the predictions are missing or incomplete.
    missing = function() {
      miss = logical(nrow(self$data$truth))
      if ("response" %in% self$predict_types) {
        miss[apply(self$response, 1, anyNA)] = TRUE
      }
      if ("se" %in% self$predict_types) {
        miss[apply(self$se, 1, anyNA)] = TRUE
      }

      self$row_ids[miss]
    }
  )
)

#' @export
as.data.table.PredictionForecast = function(x, ...) { # nolint
  # Prefix entries
  tab = map(c("truth", x$predict_types), function(type) {
    xs = copy(x$data[[type]])
    if (length(names(xs)) > 1) {
      setnames(xs, names(xs), paste0(type, ".", names(xs)))
    }
    return(xs)
  })
  tab = do.call('cbind', c(data.table("row_ids" = x$data[["row_ids"]]), tab))
  tab
}
