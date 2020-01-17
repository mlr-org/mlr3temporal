if (requireNamespace("testthat", quietly = TRUE)) {
  # TODO: library(checkmate) this is in mlr3 so we need this as well?
  library(testthat)
  library(mlr3forecasting)

  test_check("mlr3forecasting")
}
