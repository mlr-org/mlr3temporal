#' @title Auto.Arima Forecast Learner
#'
#' @name mlr_learners_regr.auto_arima
#'
#' @description
#' Auto ARIMA model
#' Calls [forecast::auto.arima] from package \CRANpkg{forecast}.
#'
#' @templateVar id forecast.auto_arima
#' @template learner
#'
#' @template seealso_learner
#' @export
#' @template example
LearnerRegrForecastAutoArima = R6::R6Class("LearnerRegrForecastAutoArima",
  inherit = LearnerForecast,

  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ps(
        d          = p_int(0L, default = NA, tags = "train", special_vals = list(NA)),
        D          = p_int(0L, default = NA, tags = "train", special_vals = list(NA)),
        max.q      = p_int(0L, default = 5, tags = "train"),
        max.p      = p_int(0L, default = 5, tags = "train"),
        max.P      = p_int(0L, default = 2, tags = "train"),
        max.Q      = p_int(0L, default = 2, tags = "train"),
        max.order  = p_int(0L, default = 5, tags = "train"),
        max.d      = p_int(0L, default = 2, tags = "train"),
        max.D      = p_int(0L, default = 1, tags = "train"),
        start.p    = p_int(0L, default = 2, tags = "train"),
        start.q    = p_int(0L, default = 2, tags = "train"),
        start.P    = p_int(0L, default = 2, tags = "train"),
        start.Q    = p_int(0L, default = 2, tags = "train"),
        stepwise   = p_lgl(default = FALSE, tags = "train"),
        allowdrift = p_lgl(default = TRUE, tags = "train"),
        seasonal   = p_lgl(default = FALSE, tags = "train")
      )

      super$initialize(
        id = "forecast.auto_arima",
        feature_types = "numeric",
        predict_types = c("response", "se"),
        packages = "forecast",
        param_set = ps,
        properties = c("univariate", "exogenous", "missings"),
        man = "mlr3temporal::mlr_learners_regr.auto_arima"
      )
    },
    #' @description
    #' Returns forecasts after the last training instance.
    forecast = function(h = 10, task, new_data = NULL) {
      if (length(task$feature_names) > 0) {
        newdata = as.matrix(new_data)
        forecast = invoke(forecast::forecast, self$model, xreg = newdata)
      } else {
        forecast = invoke(forecast::forecast, self$model, h = h)
      }
      response = as.data.table(as.numeric(forecast$mean))
      colnames(response) = task$target_names

      se = as.data.table(as.numeric(
        ci_to_se(width = forecast$upper[, 1] - forecast$lower[, 1], level = forecast$level[1])
      ))
      colnames(se) = task$target_names

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
      self$date_span =
        list(begin = list(time = span[1], row_id = task$row_ids[1]),
          end = list(time = span[2], row_id = task$row_ids[task$nrow]))
      pv = self$param_set$get_values(tags = "train")
      if ("weights" %in% task$properties) {
        pv = insert_named(pv, list(weights = task$weights$weight))
      }
      if (length(task$feature_names) > 0) {
        xreg = as.matrix(task$data(cols = task$feature_names))
        invoke(forecast::auto.arima, y = task$data(
          rows = task$row_ids,
          cols = task$target_names
        ), xreg = xreg, .args = pv)
      } else {
        invoke(forecast::auto.arima, y = task$data(
          rows = task$row_ids,
          cols = task$target_names
        ), .args = pv)
      }
    },
    .predict = function(task) {
      se = NULL
      fitted_ids = task$row_ids[task$row_ids <= self$date_span$end$row_id]
      predict_ids = setdiff(task$row_ids, fitted_ids)

      if (length(predict_ids) > 0) {
        if (length(task$feature_names) > 0) {
          newdata = as.matrix(task$data(cols = task$feature_names, rows = predict_ids))
          response_predict = invoke(forecast::forecast, self$model, xreg = newdata)
        } else {
          response_predict = invoke(forecast::forecast, self$model, h = length(predict_ids))
        }

        predict.mean = as.data.table(as.numeric(response_predict$mean))
        colnames(predict.mean) = task$target_names
        fitted.mean = self$fitted_values(fitted_ids)
        colnames(fitted.mean) = task$target_names
        response = rbind(fitted.mean, predict.mean)
        if (self$predict_type == "se") {
          predict.se = as.data.table(as.numeric(
            ci_to_se(width = response_predict$upper[, 1] - response_predict$lower[, 1],
              level = response_predict$level[1])
          ))
          colnames(predict.se) = task$target_names
          fitted.se = as.data.table(
            sapply(task$target_names, function(x) rep(sqrt(self$model$sigma2), length(fitted_ids)), simplify = FALSE)
          )
          se = rbind(fitted.se, predict.se)
        }
      } else {
        response = self$fitted_values(fitted_ids)
        if (self$predict_type == "se") {
          se = as.data.table(
            sapply(task$target_names, function(x) rep(sqrt(self$model$sigma2), length(fitted_ids)), simplify = FALSE)
          )
        }
      }

      list(response = response, se = se)
    }
  )
)

#' @include aaa.R
learners[["forecast.auto_arima"]] = LearnerRegrForecastAutoArima
