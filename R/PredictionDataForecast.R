#' @export
check_prediction_data.PredictionDataForecast <- function(pdata, ...) { # nolint
  pdata$row_ids = assert_row_ids(pdata$row_ids)
  n = length(pdata$row_ids)
  tn = colnames(pdata$truth) %??% "target"

  if (!is.null(pdata$truth)) {
    pdata$truth = as.data.table(pdata$truth)
    if (ncol(pdata$truth) == 1) {
      colnames(pdata$truth) = tn
    }
  }
  if (!is.null(pdata$response)) {
    pdata$response = as.data.table(pdata$response)
    if (ncol(pdata$response) == 1) {
      names(pdata$response) = tn
    }
  }
  if (!is.null(pdata$se)) {
    se = as.data.table(pdata$se)
    if (ncol(pdata$se) == 1) {
      names(pdata$se) = tn
    }
  }
  if (!is.null(pdata$distr)) {
    distr = as.data.table(pdata$distr)
    if (ncol(pdata$distr) == 1) {
      names(pdata$distr) = tn
    }
  }

  if (!is.null(pdata$response)) {
    pdata$response = assert_data_table(pdata$response, types = "numeric")
    assert_prediction_count(nrow(pdata$response), n, "response")
  }

  if (!is.null(pdata$se)) {
    pdata$se = assert_data_table(pdata$se, types = "numeric")
    assert_prediction_count(nrow(pdata$se), n, "se")
  }

  # FIXME: Deal with distr
  # if (!is.null(pdata$distr)) {
  #   assert_data_table(pdata$distr, types = "VectorDistribution")

  #   if (is.null(pdata$response)) {
  #     pdata$response = unname(pdata$distr$mean())
  #   }

  #   if (is.null(pdata$se)) {
  #     pdata$se = unname(pdata$distr$stdev())
  #   }
  # }

  pdata
}

#' @export
as_prediction.PredictionDataForecast = function(x, check = TRUE, ...) { # nolint
  invoke(PredictionForecast$new, .args = x)
}

#' @export
c.PredictionDataForecast = function(..., keep_duplicates = TRUE) {
  dots = list(...)
  assert_list(dots, "PredictionDataForecast")
  assert_flag(keep_duplicates)
  if (length(dots) == 1L) {
    return(dots[[1L]])
  }

  predict_types = names(mlr_reflections$learner_predict_types$forecast)
  predict_types = map(dots, function(x) intersect(names(x), predict_types))
  if (!every(predict_types[-1L], setequal, y = predict_types[[1L]])) {
    stopf("Cannot rbind predictions: Different predict types")
  }

  row_ids = unlist(map(dots, "row_ids"))

  keep = seq_len(length(row_ids))
  if (!keep_duplicates) {
    # Get a mask of non-duplicated row_ids
    keep = setdiff(keep, duplicated(row_ids))
  }

  truth = nullify_nulldt(rbindlist(map(dots, "truth"))[keep, ])
  response = nullify_nulldt(rbindlist(map(dots, "response"))[keep, ])
  se = nullify_nulldt(rbindlist(map(dots, "se"))[keep, ])
  distr = nullify_nulldt(rbindlist(map(dots, "distr"))[keep, ])

  result = list(
    row_ids = row_ids,
    truth = truth,
    response = response,
    se = se,
    distr = distr
  )
  new_prediction_data(result, "forecast")
}
