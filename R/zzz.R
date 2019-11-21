#' @import checkmate
#' @import R6
#' @import data.table
#' @import mlr3
#' @import mlr3misc
#' @importFrom digest digest
NULL

.onLoad = function(libname, pkgname) {
  x = getFromNamespace("mlr_reflections", getNamespace("mlr3"))
  x$task_types = rbind(x$task_types,
    data.table(type = "forecast", package = "mlr3forecasting",
      task = "TaskForecast", learner = "LearnerForecast",
      prediction = "PredictionForecast", measure = "MeasureForecast"))
  x$task_types = unique(x$task_types, by = "type", fromLast = TRUE)
  x$task_col_roles$forecast = x$task_col_roles$regr
}
