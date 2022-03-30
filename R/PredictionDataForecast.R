#' @export
check_prediction_data.PredictionDataForecast <- function(pdata) { # nolint
  pdata$row_ids = assert_row_ids(pdata$row_ids)
  n = length(pdata$row_ids)

  if (!is.null(pdata$response)) {
    pdata$response = assert_data_table(pdata$response, types = "numeric")
    assert_prediction_count(nrow(pdata$response), n, "response")
  }

  if (!is.null(pdata$se)) {
    pdata$se = assert_data_table(pdata$se, types = "numeric")
    assert_prediction_count(nrow(pdata$se), n, "se")
  }

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
  invoke(PredictionRegr$new, .args = x)
}
