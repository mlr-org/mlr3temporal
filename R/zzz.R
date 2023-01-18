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

#' @include aaa.R
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
  iwalk(tasks, function(obj, nm) x$add(nm, obj))

  # learners
  x = utils::getFromNamespace("mlr_learners", ns = "mlr3")
  iwalk(learners, function(obj, nm) x$add(nm, obj))

  # resampling methods ---------------------------------------------------------
  x = utils::getFromNamespace("mlr_resamplings", ns = "mlr3")
  iwalk(resamplings, function(obj, nm) x$add(nm, obj))

  # measures --------------------------------------------------------------------
  x = utils::getFromNamespace("mlr_measures", ns = "mlr3")
  iwalk(measures, function(obj, nm) x$add(nm, obj))
}

.onLoad = function(libname, pkgname) { # nolint
  register_namespace_callback(pkgname, "mlr3", register_mlr3)
}

.onUnload = function(libpaths) { # nolint
   mlr_tasks = mlr3::mlr_tasks
   walk(names(tasks), function(id) mlr_tasks$remove(id))

   mlr_learners = mlr3::mlr_learners
   walk(names(learners), function(id) mlr_learners$remove(id))

   mlr_resamplings = mlr3::mlr_resamplings
   walk(names(resamplings), function(id) mlr_resamplings$remove(id))

   mlr_measures = mlr3::mlr_measures
   walk(names(measures), function(id) mlr_measures$remove(id))
 }

leanify_package()
