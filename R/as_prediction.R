#' @rdname as_prediction
#' @export
as_prediction.PredictionDataForecast = function(x, check = TRUE, ...) { # nolint
  invoke(PredictionRegr$new, .args = x)
}
