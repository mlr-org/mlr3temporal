context("Learner Var")

test_that("autotest VAR", {
  learner = LearnerRegrForecastVAR$new()
  expect_learner(learner)
  result = run_autotest(learner, exclude = "single")
  expect_true(result, info = result$error)
})


test_that("Basic Tests", {
  task = tsk("petrol")
  learner = LearnerRegrForecastVAR$new()
  learner$train(task, row_ids = 1:6 )
  p = learner$predict(task, row_ids = 7:11)
  expect_prediction(p)

  rr = rsmp("forecast.holdout")
  rr$instantiate(task)
  res = resample(task, learner, rr, store_models = TRUE)
  res$prediction()
  expect_resample_result(res)
})
