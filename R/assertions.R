# assertion to ensure a helpful error message
assert_prediction_count = function(actual, expected, type) {
  if (actual != expected) {
    if (actual < expected) {
      stopf("Predicted %s not complete, %s for %i observations is missing",
        type, type, expected - actual)
    } else {
      stopf("Predicted %s contains %i additional predictions without matching rows",
        type, actual - expected)
    }
  }
}
