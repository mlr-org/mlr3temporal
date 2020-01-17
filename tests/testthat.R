if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  library(mlr3forecasting)

  test_check("mlr3forecasting")
}
