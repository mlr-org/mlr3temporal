#' @title Auto.Arima Learner
#'
#' @usage NULL
#' @name mlr_learners_regr.AutoArima
#' @format [R6::R6Class] inheriting from [mlr3::LearnerRegr].
#'
#' @section Construction:
#' ```
#' LearnerRegrForecastAutoArima$new()
#' mlr_learners$get("regr.rpart")
#' lrn("regr.rpart")
#' ```
#'
#' @description
#' A LearnerRegrForecast for an (AR)I(MA) model implemented in [forecast::auto.arima] in package \CRANpkg{forecast}.
#'
#'
#' @template seealso_learner
#' @export
LearnerRegrForecastAutoArima  = R6::R6Class("LearnerRegrForecastAutoArima ", inherit = LearnerForecast,
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
       properties = "univariate",
       man = "mlr3forecasting::mlr_learners_regr.AutoArima"
     )

   },

   train_internal = function(task) {
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
     if(length(task$feature_names)>0){
        newdata = as.matrix( task$data(cols = task$feature_names))
        response = invoke(forecast::forecast, self$model, xreg = newdata)
     }else{
        response = invoke(forecast::forecast, self$model, h = task$nrow)
     }
      se = (response$upper[,1] - response$lower[,1]) / (2 * qnorm(.5 + response$level[1] / 200))
      PredictionRegr$new(task = task, response = c(response$mean),se = c(se))
   }
 )
)
