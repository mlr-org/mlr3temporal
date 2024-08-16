#' @title Shift Transformation of Numeric Features
#'
#' @usage NULL
#' @name mlr_pipeops_shift
#' @format [`R6Class`][R6::R6Class] object inheriting from [`PipeOpTaskPreproc`]/[`PipeOp`].
#'
#' @description
#' Conducts a Box-Cox transformation on numeric features. The lambda parameter
#' of the transformation is estimated during training and used for both training
#' and prediction transformation.
#' See [data.table::shift()] for details.
#'
#' @section Construction:
#' ```
#' PipeOpShift$new(id = "shift", param_vals = list())
#' ```
#'
#' * `id` :: `character(1)`\cr
#'   Identifier of resulting object, default `"shift"`.
#' * `param_vals` :: named `list`\cr
#'   List of hyperparameter settings, overwriting the hyperparameter settings that would otherwise be set during construction. Default `list()`.
#'
#' @section Input and Output Channels:
#' Input and output channels are inherited from [`PipeOpTaskPreproc`].
#'
#' The output is the input [`Task`][mlr3::Task] with all affected numeric features replaced by their transformed versions.
#'
#' @section State:
#' The `$state` is a named `list` with the `$state` elements inherited from [`PipeOpTaskPreproc`],
#' as well as a list of class `shift` for each column, which is transformed.
#'
#' @section Parameters:
#' The parameters are the parameters inherited from [`PipeOpTaskPreproc`], as well as:
#' * `n` :: `numeric(1)` \cr
#'   integer vector denoting the offset by which to lead or lag the input.
#'   To create multiple lead/lag vectors, provide multiple values to n;
#'   negative values of n will "flip" the value of type, i.e., n=-1 and
#'   type='lead' is the same as n=1 and type='lag'.
#' * `fill` :: `numeric(1)` \cr
#' default is NA. Value to use for padding when the window goes beyond the input length.
#' * `typer` :: `numeric(1)` \cr
#' default is "lag" (look "backwards"). The other possible values "lead" (look "forwards"), "shift" (behave same as "lag" except given names) and "cyclic" where pushed out values are re-introduced at the front/back.
#'
#' @section Internals:
#' Uses the [`data.table::shift`] function.
#' @section Methods:
#' Only methods inherited from [`PipeOpTaskPreproc`]/[`PipeOp`].
#'
#' @examples
#' \dontshow{ if (requireNamespace("data.table")) \{ }
#' library("mlr3")
#'
#' task = tsk("iris")
#' pop = po("shift")
#'
#' task$data()
#' pop$train(list(task))[[1]]$data()
#'
#' pop$state
#' \dontshow{ \} }
#' @family PipeOps
#' @export
PipeOpShift = R6Class("PipeOpShift",
  inherit = mlr3pipelines:::PipeOpTaskPreproc,
  public = list(
    initialize = function(id = "shift", param_vals = list()) {
      ps = ps(
        min = p_int(lower=1, default = 1, tags = c("train", "shift")),
        max = p_int(lower=1, default = 1, tags = c("train", "shift")),
        fill = p_dbl(default = 0, tags = c("train", "shift"), special_vals = list(NA_real_)),
        type = p_fct(levels = c("lag", "lead", "shift", "cyclic"), default = "lag", tags = c("train", "shift")),
        give.names = p_lgl(default = TRUE, tags = c("train", "shift"))
      )
      super$initialize(id, param_set = ps, param_vals = param_vals,
        packages = "data.table", feature_types = c("numeric", "integer"))
    }
  ),
  private = list(
    .train_task = function(tsk) {
      dt = tsk$data()
      target_dt = data.table(target__ = tsk$truth())
      args = self$param_set$get_values(tags = "shift")
      args$give.names = TRUE
      min_lag = min(args$min, args$max)
      max_lag = max(args$min, args$max)
      args$n = seq(from = min_lag, to = max_lag)
      args$min = NULL
      args$max = NULL
      if (length(args$n) == 1) {
        target_lag_dt = target_dt[, .(target__lag_1 = invoke(data.table::shift, target__, .args = args))]
      } else {
        target_lag_dt = target_dt[, invoke(data.table::shift, target__, .args = args)]
      }
      bc = cbind(dt, target_lag_dt)
      self$state = list(bc = bc, target = tsk$truth(), blahblah = dt)
      blah = tsk$select(character(0))$cbind(bc)
      return(blah)
    },
    .predict_task = function(input) {
      inp = input
      dt = inp$data()
      pred_target = inp$truth()
      target_full = c(self$state$target, pred_target)
      args = self$param_set$get_values(tags = "shift")
      min_lag = min(args$min, args$max)
      max_lag = max(args$min, args$max)
      args$give.names = TRUE
      args$n = seq(from = min_lag, to = max_lag)
      args$min = NULL
      args$max = NULL
      target_dt = data.table(target__ = target_full)
      if (length(args$n) == 1) {
        target_lag_dt = target_dt[, .(target__lag_1 = invoke(data.table::shift, target__, .args = args))]
      } else {
        target_lag_dt = target_dt[, invoke(data.table::shift, target__, .args = args)]
      }
      bc = cbind(dt, tail(target_lag_dt, n = nrow(dt)))
      browser()
      blah = inp$select(character(0))$cbind(bc)
      return(blah)
    }
  )
)


mlr3pipelines:::mlr_pipeops$add("shift", PipeOpShift)
