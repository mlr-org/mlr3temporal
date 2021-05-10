if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  library(mlr3temporal)

  test_check("mlr3temporal")
}
