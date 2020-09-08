#' @title Vector Autoregression Learner
#'
#' @import vars
#'
#' @usage NULL
#' @name mlr_learners_regr.VAR
#' @format [R6::R6Class] inheriting from [LearnerForecast].
#'
#' @section Construction:
#' ```
#' LearnerRegrForecastVAR$new()
#' ```
#'
#' @description
#' A LearnerRegrForecast for a vector autoregressive model implemented in [vars::VAR] in package \CRANpkg{var}.
#'
#' @section Methods:
#' See [LearnerForecast], additionally:
#' * `forecast(h = 10, task, new_data)`  :: `data.table`\cr
#' Returns forecasts after the last training instance.
#' @template seealso_learner
#' @export
LearnerRegrForecastVAR = R6::R6Class("LearnerVAR", inherit = LearnerForecast,
  public = list(
    initialize = function() {
      ps = ParamSet$new(list(
        ParamInt$new(id = "p", default = 1, lower = 0L, tags = "train"),
        ParamInt$new(id = "lag.max", default = NULL, lower = 1L, tags = "train", special_vals = list(NULL)),
        ParamInt$new(id = "season", default = NULL, lower = 1L, tags = "train", special_vals = list(NULL))
       ))

      super$initialize(
        id = "VAR",
        feature_types = c("numeric"),
        predict_types = c("response", "se"),
        packages = "vars",
        param_set = ps,
        properties = c("multivariate", "exogenous"),
        man = "mlr3forecasting::mlr_learners_regr.VAR"
      )
    },

    forecast = function(h = 10, task, new_data = NULL) {
      if(length(task$feature_names)>0){
        newdata = as.matrix(new_data)
        forecast = invoke(predict, self$model, n.ahead = h, ci=0.95, dumvar = newdata)
      } else{
        forecast = invoke(predict, self$model, n.ahead = h, ci=0.95)
      }
      response = as.data.table(
        sapply(names(forecast$fcst), function(x) forecast$fcst[[x]][,"fcst"], simplify = FALSE)
      )
      se = as.data.table(
          sapply(names(forecast$fcst), function(x) ci_to_se(width=2*forecast$fcst[[x]][,"CI"], level = 95), simplify = FALSE)
        )
      truth = copy(response)
      truth[,colnames(truth) := 0]
      p = PredictionForecast$new(task, response = response, se = se, truth = truth,
                                 row_ids = (self$date_span$end$row_id+1):(self$date_span$end$row_id+h) )
    }
  ), 

  private = list(
    .train = function(task) {
      span = range(task$date()[[task$date_col]])
      self$date_span =
          list(begin=list(time = span[1], row_id = task$row_ids[1]), end = list(time = span[2], row_id = task$row_ids[task$nrow]))
      pv = self$param_set$get_values(tags = "train")
      if ("weights" %in% task$properties) {
        pv = insert_named(pv, list(weights = task$weights$weight))
      }
      if(length(task$feature_names) > 0){
       exogen = task$data(cols = task$feature_names)
       invoke(vars::VAR, y = task$data(rows = task$row_ids, cols=task$target_names), exogen=exogen, .args = pv)
      }else{
       invoke(vars::VAR, y = task$data(rows = task$row_ids, cols=task$target_names), .args = pv)
      }
    },

    .predict = function(task) {
      se = NULL
      fitted_ids = task$row_ids[task$row_ids <= self$date_span$end$row_id]
      predict_ids = setdiff(task$row_ids, fitted_ids)

      if(length(predict_ids > 0)){

        if(length(task$feature_names) > 0){
          exogen =  task$data(cols = task$feature_names, rows = predict_ids)
          assign("exogen", "exogen", envir = .GlobalEnv)
          forecast = invoke(predict, self$model, n.ahead = length(predict_ids), ci=0.95, dumvar = exogen)
        } else{
          forecast = invoke(predict, self$model, n.ahead = length(predict_ids), ci=0.95)
        }

        response = rbind(self$fitted_values(fitted_ids),
          as.data.table(
            sapply(names(forecast$fcst), function(x) forecast$fcst[[x]][,"fcst"], simplify = FALSE)
          )
        )
        if(self$predict_type == "se"){
          se = rbind(
            as.data.table(
              sapply(names(forecast$fcst), function(x) rep(NA,length(fitted_ids)), simplify = FALSE)),
            as.data.table(
              sapply(names(forecast$fcst), function(x) ci_to_se(width=2*forecast$fcst[[x]][,"CI"], level = 95), simplify = FALSE)
            )
          )
        }
        } else{

        response = self$fitted_values(fitted_ids)
          if(self$predict_type == "se"){
            se = as.data.table(
              sapply(names(response), function(x) rep(NA,length(fitted_ids)), simplify = FALSE)
          )
        }

      }

      p = PredictionForecast$new(task = task, response = response, se = se)

    }
  )
)
