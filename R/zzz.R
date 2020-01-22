#' @rawNamespace import(data.table, except = transpose)
#' @import paradox
#' @import mlr3misc
#' @import checkmate
#' @import mlr3
#' @import mlr3misc
#' @import tsbox
#' @importFrom R6 R6Class
#' @importFrom digest digest
#' @importFrom utils getFromNamespace
NULL


register_mlr3 = function() {
  # reflections ----------------------------------------------------------------
  x = getFromNamespace("mlr_reflections", getNamespace("mlr3"))
  x$task_types = setkeyv(rbind(x$task_types,
    data.table(type = "forecast",
      package = "mlr3forecasting",
      task = "TaskRegrForecast",
      learner = "LearnerRegrForecast",
      prediction = "PredictionRegrForecast",
      measure = "MeasureRegrForecast")),"type")
  #x$task_types = unique(x$task_types, by = "type", fromLast = TRUE)
  x$task_properties$forecast = unique(c(x$task_properties$forecast, x$task_properties$regr, c("univariate", "multivariate")))
  x$task_col_roles$forecast = x$task_col_roles$regr
  x$learner_properties$forecast = unique(c(x$learner_properties$forecast, x$learner_properties$regr, c("univariate", "multivariate")))


    # tasks --------------------------------------------------------------------
    x = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
    x$add("AirPassengers", load_task_AirPassengers)
    x$add("petrol", load_task_petrol)

    # learners
    x = utils::getFromNamespace("mlr_learners", ns = "mlr3")
    x$add("forecast.average", LearnerForeCastAverage)
    # TODO: Add all learners here.

    # resampling methods ---------------------------------------------------------
    x = utils::getFromNamespace("mlr_resamplings", ns = "mlr3")
    # TODO: Add resamplings here
}

.onLoad = function(libname, pkgname) {
  register_mlr3()
  setHook(packageEvent("mlr3", "onLoad"), function(...) register_mlr3(),
    action = "append")
}
