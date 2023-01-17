#' @import data.table
#' @import paradox
#' @import mlr3misc
#' @import checkmate
#' @import mlr3
#' @import mlr3misc
#' @importFrom R6 R6Class
#' @importFrom digest digest
#' @importFrom utils getFromNamespace
#' @importFrom ggplot2 autoplot
NULL


register_mlr3 = function() {
  # reflections ----------------------------------------------------------------
  x = getFromNamespace("mlr_reflections", getNamespace("mlr3"))

  x$task_types = rbind(x$task_types, data.table(
    type = "forecast",
    package = "mlr3temporal",
    task = "TaskRegrForecast",
    learner = "LearnerRegrForecast",
    prediction = "PredictionRegrForecast",
    prediction_data = "PredictionDataForecast",
    measure = "MeasureForecast"
  ))
  setkeyv(x$task_types, "type")
  x$task_properties$forecast = unique(c(
    x$task_properties$forecast, x$task_properties$regr,
    c("univariate", "multivariate", "exogenous", "missings")
  ))
  x$task_col_roles$forecast = unique(c(x$task_col_roles$regr, "date_col"))
  x$learner_predict_types$forecast = x$learner_predict_types$regr
  x$learner_properties$forecast = unique(c(
    x$learner_properties$forecast,
    x$learner_properties$regr,
    c("univariate", "multivariate", "exogenous")
  ))
  x$measure_properties$forecast = x$measure_properties$regr
  x$default_measures$forecast = "forecast.mae"
  # tasks --------------------------------------------------------------------
  x = utils::getFromNamespace("mlr_tasks", ns = "mlr3")
  x$add("airpassengers", load_task_air_passengers)
  x$add("petrol", load_task_petrol)

  # learners
  x = utils::getFromNamespace("mlr_learners", ns = "mlr3")
  x$add("forecast.average", LearnerRegrForecastAverage)
  x$add("forecast.auto.arima", LearnerRegrForecastAutoArima)
  x$add("forecast.VAR", LearnerRegrForecastVAR)
  # FIXME: Add all learners here.

  # resampling methods ---------------------------------------------------------
  x = utils::getFromNamespace("mlr_resamplings", ns = "mlr3")
  x$add("forecastHoldout", ResamplingForecastHoldout)
  x$add("RollingWindowCV", ResamplingRollingWindowCV)
  # FIXME: Add resamplings here

  # measures --------------------------------------------------------------------
  x = utils::getFromNamespace("mlr_measures", ns = "mlr3")
  x$add("forecast.mae", MeasureForecastMAE)
  x$add("forecast.mape", MeasureForecastMAPE)
  x$add("forecast.rmse", MeasureForecastRMSE)
  x$add("forecast.mse", MeasureForecastMSE)
}

.onLoad = function(libname, pkgname) { # nolint
  register_mlr3()
  setHook(packageEvent("mlr3", "onLoad"), function(...) register_mlr3(),
    action = "append"
  )
}
