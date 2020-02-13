#' @title Visualization for forecasting
#'
#' @description 
#' Generates plots for the [mlr3forecasting::prediction] of the [mlr3forecasting::learner] on a [mlr3forecasting::task]
#' @import ggplot2
#'
#' @param object is mlr3 forcasting resampling object.
#' @param task [TaskRegr]/[TaskSupervised] and [TaskForecast]
#'   mlr3 task object.
#' @param fold_id [numeric]\cr
#'   Fold IDs to plot.
#' @param repeats_id [numeric]\cr
#'   Repetition ID to plot.
#' @param grid (`logical(1)`)\cr Should a gridded plot using
#'   `cowplot::plot_grid()` be created? If `FALSE` only a list with all
#'   \CRANpkg{ggplot2} resamplings is returned. Default is `TRUE`. Only applies
#'   if a numeric vector is passed to argument `fold_id`.
#' @param train_color `character(1)`\cr
#'   The color to use for the training set observations.
#' @param test_color `character(1)`\cr
#'   The color to use for the test set observations.
#' @param ... Not used.
#'
#' @details By default a plot is returned; if `fold_id` is set, a gridded plot
#'   is created. If `grid = FALSE`, only a list of ggplot2 resamplings is
#'   returned. This gives the option to align the single plots manually.
#'
#'   When no single fold is selected, the [ggsci::scale_color_ucscgb()] palette
#'   is used to display all partitions. If you want to change the colors,
#'   call `<plot> + <color-palette>()`
#' @return [ggplot()] or list of ggplot2 objects.

#' @title Plot for Forecasting in mlr3


```r
library(mlr3)
autoplot.forecasting = function(
  object,
  task,
  fold_id = NULL,
  grid = TRUE,
  train_color = "#0072B5",
  test_color = "#E18727",
  ...) {
  autoplot_spatial(resampling = object,
    task = task,
    fold_id = fold_id,
    grid = grid)
}
```

