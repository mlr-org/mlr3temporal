test_that("autotest", {
  learner = LearnerRegrForecastAutoArima$new()
  expect_learner(learner)
  # result = run_autotest(learner)
  # expect_true(result, info = result$error)
})

test_that("Basic Tests", {
  learner = LearnerRegrForecastAutoArima$new()
  tsk = mlr_tasks$get("AirPassengers")
  learner$train(tsk)
})
