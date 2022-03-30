#' @title Plot for Forecast Tasks
#'
#'
#' @description
#' Generates plots for [mlr3temporal::TaskForecast]
#'
#' @param object ([mlr3temporal::TaskForecast]).
#' @param ... (`any`):
#'   Additional argument, passed down to the underlying `geom` or plot functions.
#'
#' @return [ggplot2::ggplot()] object.
#' @export
#' @examples
#' library(mlr3)
#' library(mlr3temporal)
#' library(ggplot2)
#'
#' task = tsk("airpassengers")
#' autoplot(task)
#'
#' task = tsk("petrol")
#' autoplot(task)
autoplot.TaskForecast = function(object, ...) { # nolint
  data = data.table(object$data(), object$date())
  date = object$date_col
  target = object$target_names
  data_long = melt(data, id.vars = date, measure.vars = target)

  ggplot(data_long, aes_string(x = date)) +
    geom_line(aes_string(y = "value", col = "variable")) +
    xlab("")
}
