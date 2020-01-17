#' @rawNamespace import(data.table, except = transpose)
#' @import paradox
#' @import mlr3misc
#' @import checkmate
#' @import mlr3
#' @import mlr3misc
#' @import tsbox
#' @importFrom R6 R6Class
#' @importFrom digest digest
NULL


register_mlr3 = function() {
  # reflections ----------------------------------------------------------------
  x = getFromNamespace("mlr_reflections", getNamespace("mlr3"))
  x$task_types = rbind(x$task_types,
    data.table(type = "forecast", package = "mlr3forecasting",
      task = "TaskRegrForecast",
      learner = "LearnerRegrForecast",
      prediction = "PredictionRegrForecast",
      measure = "MeasureRegrForecast"))
  x$task_types = unique(x$task_types, by = "type", fromLast = TRUE)
  x$task_properties$forecast = unique(c(x$task_properties$forecast, x$task_properties$regr, c("univariate", "multivariate")))
  x$task_col_roles$forecast = x$task_col_roles$regr

    # tasks --------------------------------------------------------------------
    x = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
    x$add("AirPassengers", load_task_AirPassengers)
    x$add("petrol", load_task_petrol)

    # learners
    x = utils::getFromNamespace("mlr_learners", ns = "mlr3")
    x$add("forecast.average", LearnerForeCastAverage)


    # resampling methods ---------------------------------------------------------
    x = utils::getFromNamespace("mlr_resamplings", ns = "mlr3")

}

.onLoad = function(libname, pkgname) {
  register_mlr3()
  setHook(packageEvent("mlr3", "onLoad"), function(...) register_mlr3(),
    action = "append")
}
