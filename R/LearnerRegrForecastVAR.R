#' @title Vector Autoregression Forecast Learner
#'
#' @name mlr_learners_regr.VAR
#'
#' @description
#' Vector autoregressive model
#' Calls [vars::VAR] from package \CRANpkg{vars}.
#'
#' @templateVar id forecast.VAR
#' @template learner
#'
#' @template seealso_learner
#' @export
#' @template example
LearnerRegrForecastVAR = R6::R6Class("LearnerVAR",
  inherit = LearnerForecast,

  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ps(
        p       = p_int(0L, default = 1, tags = "train"),
        lag.max = p_int(1L, default = NULL, tags = "train", special_vals = list(NULL)),
        season  = p_int(1L, default = NULL, tags = "train", special_vals = list(NULL))
      )

      super$initialize(
        id = "forecast.VAR",
        feature_types = c("numeric"),
        predict_types = c("response", "se"),
        packages = "vars",
        param_set = ps,
        properties = c("multivariate", "exogenous", "missings"),
        man = "mlr3temporal::mlr_learners_regr.VAR"
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
    #' @param newdata ([data.frame()])\cr
    #'   New data to predict on.
    #'
    #' @return [Prediction].
    forecast = function(h = 10, task, newdata = NULL) {
      h = assert_int(h, lower = 1, coerce = TRUE)
      if (length(task$feature_names) > 0) {
        newdata = as.matrix(newdata)
        forecast = invoke(predict, self$model, n.ahead = h, ci = 0.95, dumvar = newdata)
      } else {
        forecast = invoke(predict, self$model, n.ahead = h, ci = 0.95)
      }
      response = as.data.table(
        sapply(names(forecast$fcst), function(x) forecast$fcst[[x]][, "fcst"], simplify = FALSE)
      )
      se = as.data.table(
        sapply(names(forecast$fcst), function(x) {
          ci_to_se(width = 2 * forecast$fcst[[x]][, "CI"], level = 95)
        }, simplify = FALSE)
      )
      truth = copy(response)
      truth[, colnames(truth) := 0]
      p = PredictionForecast$new(task,
        response = response, se = se, truth = truth,
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
      pv = self$param_set$get_values(tags = "train")
      if ("weights" %in% task$properties) {
        pv = insert_named(pv, list(weights = task$weights$weight))
      }

      tgts = task$data(rows = task$row_ids, cols = task$target_names)
      tgts = na.omit(tgts)
      row_ids = task$row_ids[which(!apply(tgts, 1, function(x) all(is.na(x))))]
      if (length(task$feature_names) > 0) {
        exogen = task$data(rows = row_ids, cols = task$feature_names)
        invoke(vars::VAR, y = tgts, exogen = exogen, .args = pv)
      } else {
        invoke(vars::VAR, y = tgts, .args = pv)
      }
    },

    .predict = function(task) {
      se = NULL
      fitted_ids = task$row_ids[task$row_ids <= self$date_span$end$row_id]
      predict_ids = setdiff(task$row_ids, fitted_ids)

      if (length(predict_ids > 0)) {
        if (length(task$feature_names) > 0) {
          exogen = task$data(cols = task$feature_names, rows = predict_ids)
          assign("exogen", "exogen", envir = .GlobalEnv)
          forecast = invoke(predict, self$model, n.ahead = length(predict_ids), ci = 0.95, dumvar = exogen)
        } else {
          forecast = invoke(predict, self$model, n.ahead = length(predict_ids), ci = 0.95)
        }

        response = rbind(
          self$fitted_values(fitted_ids),
          as.data.table(
            sapply(names(forecast$fcst), function(x) forecast$fcst[[x]][, "fcst"], simplify = FALSE)
          )
        )
        if (self$predict_type == "se") {
          se = rbind(
            as.data.table(
              sapply(names(forecast$fcst), function(x) rep(NA_real_, length(fitted_ids)), simplify = FALSE)
            ),
            as.data.table(
              sapply(names(forecast$fcst), function(x) {
                ci_to_se(width = 2 * forecast$fcst[[x]][, "CI"], level = 95)
              }, simplify = FALSE)
            )
          )
        }
      } else {
        response = self$fitted_values(fitted_ids)
        if (self$predict_type == "se") {
          se = as.data.table(
            sapply(names(response), function(x) rep(NA_real_, length(fitted_ids)), simplify = FALSE)
          )
        }
      }

      list(response = response, se = se)
    }
  )
)

#' @include aaa.R
learners[["forecast.VAR"]] = LearnerRegrForecastVAR
