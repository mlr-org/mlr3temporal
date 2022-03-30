#' @rdname PredictionData
#' @export
check_prediction_data.PredictionDataForecast <- function(pdata) { # nolint
  pdata$row_ids = assert_row_ids(pdata$row_ids)
  n = length(pdata$row_ids)

  if (!is.null(pdata$response)) {
    pdata$response = assert_numeric(unname(pdata$response))
    assert_prediction_count(length(pdata$response), n, "response")
  }

  if (!is.null(pdata$se)) {
    pdata$se = assert_numeric(unname(pdata$se), lower = 0)
    assert_prediction_count(length(pdata$se), n, "se")
  }

  if (!is.null(pdata$distr)) {
    assert_class(pdata$distr, "VectorDistribution")

    if (is.null(pdata$response)) {
      pdata$response = unname(pdata$distr$mean())
    }

    if (is.null(pdata$se)) {
      pdata$se = unname(pdata$distr$stdev())
    }
  }

  pdata
}
