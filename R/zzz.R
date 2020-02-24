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
      measure = "MeasureForecast")),"type")
  x$task_properties$forecast = unique(c(x$task_properties$forecast, x$task_properties$regr,
                                        c("univariate", "multivariate", "exogenous")))
  x$task_col_roles$forecast = x$task_col_roles$regr
  x$learner_predict_types$forecast = x$learner_predict_types$regr
  x$learner_properties$forecast = unique(c(x$learner_properties$forecast,
                                          x$learner_properties$regr,
                                          c("univariate", "multivariate", "exogenous")))
  x$measure_properties$forecast = x$measure_properties$regr
  x$default_measures$forecast = "forecast.mae"
  # tasks --------------------------------------------------------------------
  x = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
  x$add("airpassengers", load_task_AirPassengers)
  x$add("petrol", load_task_petrol)

  # learners
  x = utils::getFromNamespace("mlr_learners", ns = "mlr3")
  x$add("forecast.average", LearnerForecastAverage)
  x$add("forecast.auto.arima", LearnerRegrForecastAutoArima)
  x$add("forecast.VAR", LearnerRegrForecastVAR)
  # FIXME: Add all learners here.

  # resampling methods ---------------------------------------------------------
  x = utils::getFromNamespace("mlr_resamplings", ns = "mlr3")
  x$add("forecast.holdout", ResamplingForecastHoldout)
  x$add("RollingWindowCV", ResamplingRollingWindowCV)
  # FIXME: Add resamplings here

  # measures --------------------------------------------------------------------
  x = utils::getFromNamespace("mlr_measures", ns = "mlr3")
  x$add("forecast.mae", MeasureForecastMAE)
}

.onLoad = function(libname, pkgname) {
  register_mlr3()
  setHook(packageEvent("mlr3", "onLoad"), function(...) register_mlr3(),
    action = "append")
}
