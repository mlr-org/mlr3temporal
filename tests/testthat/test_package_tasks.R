context("Included Tasks")

test_that("air_passengers", {
  tsk = mlr_tasks$get("airpassengers")
  expect_task(tsk)
  expect_subset("univariate", tsk$properties)
})

test_that("petrol", {
  tsk = mlr_tasks$get("petrol")
  expect_task(tsk)
  expect_subset("multivariate", tsk$properties)
})

