#' @title Vector Autoregression Learner
#'
#' @usage NULL
#' @name mlr_learners_regr.Auto.Arima
#' @format [R6::R6Class] inheriting from [LearnerRegr].
#' @include LearnerRegr.R
#'
#' @section Construction:
#' ```
#' LearnerRegrForecastMultivVAR$new()

#' ```
#'
#' @description
#' A [LearnerRegr] for a vector autoregressive model  implemented in [vars::VAR] in package \CRANpkg{var}.
#'
#'
#' @template seealso_learner
#' @export

LearnerRegrForecastMultivVAR= R6::R6Class("LearnerVAR", inherit = LearnerRegr,
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
       properties = c("weights", "missings")
     )

   },

   train_internal = function(task) {
     pv = self$param_set$get_values(tags = "train")
     if ("weights" %in% task$properties) {
       pv = insert_named(pv, list(weights = task$weights$weight))
     }
     if(length(task$feature_names)>0){
      exogen = task$data(cols = task$feature_names)
      invoke(vars::VAR, y = task$data(rows = task$row_ids,cols=task$target_names),
      exogen=exogen,.args = pv)
     }else{
      invoke(vars::VAR, y = task$data(rows = task$row_ids,cols=task$target_names), .args = pv)
     }
   },

   predict_internal = function(task) {
      # FIXME ....
     response = invoke(predict, self$model, h = task$nrow)
     PredictionRegr$new(task = task, response = c(response$mean))
   }


 )
)


