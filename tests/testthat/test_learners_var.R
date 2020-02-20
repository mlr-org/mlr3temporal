test_that("autotest VAR", {
  learner = LearnerRegrForecastVAR$new()
  expect_learner(learner)
  result = run_autotest(learner, exclude = "single")
  expect_true(result, info = result$error)
})


test_that("Basic Tests", {
  learner = LearnerRegrForecastVAR$new()
  tsk = mlr_tasks$get("petrol")
  learner$train(tsk, 1:20)
  expect_prediction(learner$predict(tsk, 21:30))
})
