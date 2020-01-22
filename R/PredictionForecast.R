PredictionForecast = R6::R6Class("PredictionForecast", inherit = Prediction,
  cloneable = FALSE,
  public = list(
    initialize = function(task = NULL, row_ids = task$row_ids, truth = task$truth(), se = NULL, response = NULL) {
      # assert_row_ids(row_ids)
      n = length(row_ids)

      self$task_type = "forecast"
      self$predict_types = c("response","se")[c(!is.null(response), !is.null(se))]
      self$data$tab = data.table(
        row_id = row_ids,
        truth = assert_numeric(truth, len = n, null.ok = TRUE)
      )

      if (!is.null(response)) {
        self$data$tab$response = assert_numeric(response, len = n, any.missing = FALSE)
      }
      if (!is.null(se)) {
        self$data$tab$se = assert_numeric(se, len = n, any.missing = FALSE)
      }
    },

    help = function() {
      open_help("mlr3forecasting::PredictionForecast")
    }
  ),

  active = list(
    response = function() {
      self$data$tab$response %??% rep(NA_real_, length(self$data$row_ids))
    },

    se = function() {
      self$data$tab$se %??% rep(NA_real_, length(self$data$row_ids))
    },

    missing = function() {
      miss = is.na(self$response)
      self$data$tab$row_id[miss]
    }
  )
)

#' @export
as.data.table.PredictionForecast = function(x, ...) {
  copy(x$data$tab)
}

#' @export
c.PredictionForecast = function(..., keep_duplicates = TRUE) {
  dots = list(...)
  assert_list(dots, "PredictionRegr")
  assert_flag(keep_duplicates)
  if (length(dots) == 1L) {
    return(dots[[1L]])
  }

  predict_types = map(dots, "predict_types")
  if (!every(predict_types[-1L], setequal, y = predict_types[[1L]])) {
    stopf("Cannot rbind predictions: Probabilities for some predictions, not all")
  }

  tab = map_dtr(dots, function(p) p$data$tab, .fill = FALSE)

  if (!keep_duplicates) {
    tab = unique(tab, by = "row_id", fromLast = TRUE)
  }

  PredictionForecast$new(row_ids = tab$row_id, truth = tab$truth, response = tab$response, se = tab$se)
}
