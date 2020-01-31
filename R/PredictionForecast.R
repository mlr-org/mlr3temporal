#' @title Prediction Object for Forecasting
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [Prediction].
#' @include PredictionForecast.R
#'
#' @description
#' This object wraps the predictions returned by a learner of class LearnerForecast, i.e.
#' the predicted response and standard error.
#'
#' @section Construction:
#' ```
#' p = PredictionForecast$new(task = NULL, row_ids = task$row_ids, truth = task$truth(), response = NULL, se = NULL)
#' ```
#'
#' * `task` :: [TaskRegrForecast]\cr
#'   Task, used to extract defaults for `row_ids` and `truth`.
#'
#' * `row_ids` :: `integer()`\cr
#'   Row ids of the predicted observations, i.e. the row ids of the test set.
#'
#' * `truth` :: `numeric()`\cr
#'     True (observed) outcome.
#'
#' * `response` :: `numeric()`\cr
#'   Object of numeric response values that can be coerced to a data.table.
#'
#' * `se` :: `numeric()`\cr
#'   Object of numeric standard erros that can be coerced to a data.table.
#'
#' @section Fields:
#' All fields from [Prediction], and additionally:
#'
#' * `response` :: `numeric()`\cr
#'   Access to the stored predicted response.
#'
#' * `se` :: `numeric()`\cr
#'   Access to the stored standard error.
#'
#' The field `task_type` is set to `"forecast"`.
#'
#' @family Prediction
#' @export
#' @examples
#' task = mlr3::tsk("airpassengers")
#' learner=LearnerRegrForecastAutoArima$new()
#' learner$train(task)
#' p=learner$predict(task)
PredictionForecast = R6::R6Class("PredictionForecast", inherit = Prediction,
  cloneable = FALSE,
  public = list(
    initialize = function(task = NULL, row_ids = task$row_ids, truth = task$truth(), response = NULL, se = NULL) {

      assert_row_ids(row_ids)
      n = length(row_ids)
      self$task_type = "forecast"
      self$predict_types = c("response","se")[c(!is.null(response), !is.null(se))]

      truth = as.data.table(truth)
      if(ncol(truth)==1){
        names(truth) = task$target_names
      }
      self$data$tab$truth = data.table(
        row_id = row_ids,
        assert_data_table(truth, types = c("numeric"), null.ok = TRUE, nrows = n)
      )

      if (!is.null(response)) {
        response = as.data.table(response)
        if(ncol(response)==1){
          names(response) = task$target_names
        }
        self$data$tab$response = data.table(
          row_id = row_ids,
          assert_data_table(response, types = c("numeric"), null.ok = TRUE, nrows = n, any.missing = FALSE)
        )
      }

      if (!is.null(se)) {
        se = as.data.table(se)
        if(ncol(se)==1){
          names(se) = task$target_names
        }
        self$data$tab$se = data.table(
          row_id = row_ids,
          assert_data_table(se, types = c("numeric"), null.ok = TRUE, nrows = n, any.missing = FALSE)
        )
      }

    },

    help = function() {
      open_help("mlr3forecasting::PredictionForecast")
    },

    print = function(...) {
      data = as.data.table(self)
      if (!nrow(data)) {
        catf("%s for 0 observations", format(self))
      } else {
        catf("%s for %i observations:", format(self), nrow(data))
        print(data, nrows = 10L, topn = 3L, class = FALSE, row.names = FALSE, print.keys = FALSE)
      }
    }
  ),

  active = list(

    row_ids = function() self$data$tab$truth$row_id,
    truth = function() self$data$tab$truth,

    response = function() {
      self$data$tab$response %??% rep(NA_real_, length(self$data$tab$truth$row_id))
    },

    se = function() {
      self$data$tab$se %??% rep(NA_real_, length(self$data$tab$truth$row_id))
    },

    missing = function() {
      miss = logical(nrow(self$data$tab$truth))
      if ("response" %in% self$predict_types) {
        miss[which(is.na(self$response[,-1]), arr.ind = TRUE)[1]] = TRUE
      }
      if ("se" %in% self$predict_types) {
        miss[which(is.na(self$se[,-1]), arr.ind = TRUE)[1]] = TRUE
      }

      self$data$tab$truth$row_id[miss]
    }
  )
)


#' @export
as.data.table.PredictionForecast = function(x, ...) {

  tab = copy(x$data$tab$truth)
  setnames(tab,names(tab)[-1],paste0("truth.", names(tab)[-1]),skip_absent=TRUE)

  if("response" %in% x$predict_types){
    response = as.data.table(x$data$tab$response[,-1])
    setnames(response, names(response), paste0("response.", names(response)))
    tab = rcbind(tab, response)
  }

  if("se" %in% x$predict_types){
    se = as.data.table(x$data$tab$se[,-1])
    setnames(se, names(se), paste0("se.", names(se)))
    tab = rcbind(tab, se)
  }

  return(tab)
}

#' @export
c.PredictionForecast = function(..., keep_duplicates = TRUE) {
  dots = list(...)
  assert_list(dots, "PredictionForecast")
  assert_flag(keep_duplicates)
  if (length(dots) == 1L) {
    return(dots[[1L]])
  }

  predict_types = map(dots, "predict_types")
  if (!every(predict_types[-1L], setequal, y = predict_types[[1L]])) {
    stopf("Cannot rbind predictions: Standard Errors for some predictions, not all")
  }
  tab = list()
  tab$truth = map_dtr(dots, function(p) p$data$tab$truth, .fill = FALSE)
  tab$response = map_dtr(dots, function(p) p$data$tab$response, .fill = FALSE)
  tab$se = map_dtr(dots, function(p) p$data$tab$se, .fill = FALSE)

  if (!keep_duplicates) {
    tab$truth = unique(tab$truth, by = "row_id", fromLast = TRUE)
    tab$response = unique(tab$truth, by = "row_id", fromLast = TRUE)
    tab$se = unique(tab$truth, by = "row_id", fromLast = TRUE)
  }

 PredictionForecast$new(row_ids = tab$truth$row_id, truth = tab$truth[,-1], response = tab$response[,-1], se = tab$se[,-1])
}
