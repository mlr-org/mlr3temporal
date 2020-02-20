#' @title Vector Autoregression Learner
#'
#' @usage NULL
#' @name mlr_learners_regr.VAR
#' @format [R6::R6Class] inheriting from [mlr3::LearnerRegr].
#'
#' @section Construction:
#' ```
#' LearnerRegrForecastVAR$new()
#' ```
#'
#' @description
#' A LearnerRegrForecast for a vector autoregressive model implemented in [vars::VAR] in package \CRANpkg{var}.
#'
#'
#' @template seealso_learner
#' @export
LearnerRegrForecastVAR = R6::R6Class("LearnerVAR", inherit = LearnerForecast,
 public = list(
   initialize = function() {
     ps = ParamSet$new(list(
       ParamInt$new(id = "p", default = 1, lower = 0L, tags = "train"),
       ParamInt$new(id = "lag.max", default = NULL, lower = 1L, tags = "train",special_vals = list(NULL)),
       ParamInt$new(id = "season", default = NULL, lower = 1L, tags = "train",special_vals = list(NULL))
      ))

     super$initialize(
       id = "VAR",
       feature_types = c("numeric"),
       predict_types = c("response","se"),
       packages = "vars",
       param_set = ps,
       properties = c("multivariate"),
       man = "mlr3forecasting::mlr_learners_regr.VAR"
     )
   },

   train_internal = function(task) {
     pv = self$param_set$get_values(tags = "train")
     if ("weights" %in% task$properties) {
       pv = insert_named(pv, list(weights = task$weights$weight))
     }
     if(length(task$feature_names)>0){
      exogen = task$data(cols = task$feature_names)
      invoke(vars::VAR, y = task$data(rows = task$row_ids,cols=task$target_names), exogen=exogen,.args = pv)
     }else{
      invoke(vars::VAR, y = task$data(rows = task$row_ids,cols=task$target_names), .args = pv)
     }
   },

   predict_internal = function(task) {
     if(length(task$feature_names)>0){
       exogen =  task$data(cols = task$feature_names)
       assign("exogen", "exogen", envir = .GlobalEnv)
       forecast = invoke(predict, self$model, n.ahead = task$nrow,ci=0.95, dumvar=exogen)
     } else{
        forecast = invoke(predict, self$model, n.ahead = task$nrow, ci=0.95)
     }
     response = data.table(
        sapply(names(forecast$fcst), function(x) forecast$fcst[[x]][,"fcst"])
     )
     se = data.table(
        sapply(names(forecast$fcst), function(x) ci_to_se(width=2*forecast$fcst[[x]][,"CI"], level = 95))
     )
     p=PredictionForecast$new(task = task, response = response, se = se)
   }
 )
)
