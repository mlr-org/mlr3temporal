context("Resampling")

test_that("re-instantiating", {
  t1 = tsk("petrol")
  t2 = tsk("airpassengers")
  r = rsmp("RollingWindowCV", folds = 2)

  expect_resampling(r$instantiate(t1), task = t1)
  expect_resampling(r$instantiate(t2), task = t2)

  r = rsmp("forecastHoldout", ratio = 0.5)

  expect_resampling(r$instantiate(t1), task = t1)
  expect_resampling(r$instantiate(t2), task = t2)


  r = rsmp("custom")
  expect_error(r$instantiate(t1), "missing")

  expect_resampling(r$instantiate(t1, train_sets = list(1), test_sets = list(1)), task = t1)
  expect_resampling(r$instantiate(t2, train_sets = list(1), test_sets = list(2)), task = t2)
})

test_that("param_vals", {
  task = tsk("petrol")
  r = rsmp("RollingWindowCV", folds = 10L, horizon = 3L, window_size = 5L, fixed_window = FALSE)
  expect_identical(r$param_set$values$folds, 10L)
  expect_identical(r$param_set$values$horizon, 3L)
  expect_identical(r$param_set$values$window_size, 5L)
  expect_identical(r$param_set$values$fixed_window, FALSE)
  r$instantiate(task)
  expect_true(r$is_instantiated)
  expect_identical(r$iters, 10L)
  expect_equal(intersect (r$test_set(1),r$train_set(1)), integer(0))
  expect_integerish(r$test_set(10), len = 3)
  expect_resampling(r)

  task = tsk("petrol")
  r = rsmp("forecastHoldout", ratio = 0.7)
  expect_identical(r$param_set$values$ratio, 0.7)
  r$instantiate(task)
  expect_true(r$is_instantiated)
  expect_identical(r$iters, 1L)
  expect_equal(intersect (r$test_set(1),r$train_set(1)), integer(0))
  expect_resampling(r)
})
