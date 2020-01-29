test_that("autotest VAR", {
  learner = LearnerRegrForecastVAR$new()
  expect_learner(learner)
  # result = run_autotest(learner)
  # expect_true(result, info = result$error)
})

test_that("Basic Tests", {
  learner = LearnerRegrForecastVAR$new()
  tsk = mlr_tasks$get("petrol")
  learner$train(tsk)
  expect_prediction(learner$predict(tsk))
})
