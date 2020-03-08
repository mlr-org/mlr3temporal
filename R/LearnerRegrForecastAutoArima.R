#' @title Auto.Arima Learner
#'
#' @import forecast
#' @usage NULL
#' @name mlr_learners_regr.AutoArima
#' @format [R6::R6Class] inheriting from [LearnerForecast].
#'
#' @section Construction:
#' ```
#' LearnerRegrForecastAutoArima$new()
#' mlr_learners$get("regr.rpart")
#' lrn("regr.rpart")
#' ```
#' @section Methods:
#' See [LearnerForecast], additionally:
#' * `forecast(h = 10, task, new_data)`  :: `data.table`\cr
#' Returns forecasts after the last training instance.
#' @description
#' A LearnerRegrForecast for an (AR)I(MA) model implemented in [forecast::auto.arima] in package \CRANpkg{forecast}.
#'
#'
#' @template seealso_learner
#' @export
LearnerRegrForecastAutoArima  = R6::R6Class("LearnerRegrForecastAutoArima ",
  inherit = LearnerForecast,
  public = list(
    initialize = function() {
      ps = ParamSet$new(list(
        ParamInt$new(id = "d", default = NA, lower = 0L, tags = "train",special_vals = list(NA)),
        ParamInt$new(id = "D", default = NA, lower = 0L, tags = "train",special_vals = list(NA)),
        ParamInt$new(id = "max.p", default = 5, lower = 0, tags = "train"),
        ParamInt$new(id = "max.q", default = 5, lower = 0, tags = "train"),
        ParamInt$new(id = "max.P", default = 2, lower = 0, tags = "train"),
        ParamInt$new(id = "max.Q", default = 2, lower = 0, tags = "train"),
        ParamInt$new(id = "max.order", default = 5, lower = 0, tags = "train"),
        ParamInt$new(id = "max.d", default = 2, lower = 0, tags = "train"),
        ParamInt$new(id = "max.D", default = 1, lower = 0, tags = "train"),
        ParamInt$new(id = "start.p", default = 2, lower = 0, tags = "train"),
        ParamInt$new(id = "start.q", default = 2, lower = 0, tags = "train"),
        ParamInt$new(id = "start.P", default = 2, lower = 0, tags = "train"),
        ParamInt$new(id = "start.Q", default = 2, lower = 0, tags = "train"),
        ParamLgl$new(id = "stepwise",default = FALSE,tags = "train"),
        ParamLgl$new(id = "allowdrift",default = TRUE,tags = "train"),
        ParamLgl$new(id = "seasonal",default = FALSE,tags = "train")
      ))

      super$initialize(
        id = "auto.arima",
        feature_types = "numeric",
        predict_types = c("response", "se"),
        packages = "forecast",
        param_set = ps,
        properties = c("univariate", "exogenous", "missings"),
        man = "mlr3forecasting::mlr_learners_regr.AutoArima"
      )
    },

    train_internal = function(task) {
      span = range(task$date()[[task$date_col]])
      self$date_span =
        list(begin=list(time = span[1], row_id = task$row_ids[1]), end = list(time = span[2], row_id = task$row_ids[task$nrow]))
      pv = self$param_set$get_values(tags = "train")
      if ("weights" %in% task$properties) {
        pv = insert_named(pv, list(weights = task$weights$weight))
      }
      if (length(task$feature_names)>0) {
        xreg = as.matrix( task$data(cols = task$feature_names))
        invoke(forecast::auto.arima, y = task$data(rows = task$row_ids,
          cols=task$target_names), xreg = xreg, .args = pv)
      } else {
        invoke(forecast::auto.arima, y = task$data(rows = task$row_ids,
          cols=task$target_names),.args = pv)
      }
    },

    predict_internal = function(task) {
      se = NULL
      fitted_ids = task$row_ids[task$row_ids <= self$date_span$end$row_id]
      predict_ids = setdiff(task$row_ids, fitted_ids)

      if(length(predict_ids) > 0){
        if (length(task$feature_names) > 0) {
          newdata = as.matrix( task$data(cols = task$feature_names, rows = predict_ids))
          response.predict = invoke(forecast::forecast, self$model, xreg = newdata)
        } else {
          response.predict = invoke(forecast::forecast, self$model, h = length(predict_ids))
        }

        predict.mean = as.data.table(as.numeric(response.predict$mean))
        colnames(predict.mean) = task$target_names
        fitted.mean = self$fitted_values(fitted_ids)
        colnames(fitted.mean) = task$target_names
        response = rbind(fitted.mean, predict.mean)
        if(self$predict_type == "se"){
          predict.se = as.data.table(as.numeric(
            ci_to_se(width = response.predict$upper[,1] - response.predict$lower[,1], level = response.predict$level[1])
          ))
          colnames(predict.se) = task$target_names
          fitted.se = as.data.table(
            sapply(task$target_names, function(x) rep(sqrt(self$model$sigma2),length(fitted_ids)), simplify = FALSE))
          se = rbind(fitted.se, predict.se)
        }
      } else {
        response = self$fitted_values(fitted_ids)
        if(self$predict_type == "se"){
          se = as.data.table(
            sapply(task$target_names, function(x) rep(sqrt(self$model$sigma2),length(fitted_ids)), simplify = FALSE)
          )
        }
      }

      p = PredictionForecast$new(task = task, response = response, se = se)

    },

    forecast = function(h = 10, task, new_data = NULL) {
      if(length(task$feature_names)>0){
        newdata = as.matrix(new_data)
        forecast = invoke(forecast::forecast, self$model, xreg = newdata)
      } else{
        forecast = invoke(forecast::forecast, self$model, h = h)
      }
      response = as.data.table(as.numeric(forecast$mean))
      colnames(response) = task$target_names

      se = as.data.table(as.numeric(
        ci_to_se(width = forecast$upper[,1] - forecast$lower[,1], level = forecast$level[1])
      ))
      colnames(se) = task$target_names

      truth = copy(response)
      truth[,colnames(truth) := 0]
      p = PredictionForecast$new(task, response = response, se = se, truth = truth,
        row_ids = (self$date_span$end$row_id+1):(self$date_span$end$row_id+h) )
    }
  )
)
