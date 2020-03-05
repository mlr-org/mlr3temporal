context("learners_average")

test_that("autotest", {
  learner = LearnerRegrForecastAverage$new()
  expect_learner(learner)
  result = run_autotest(learner)
  expect_true(result, info = result$error)
})

test_that("Basic Tests", {
  learner = LearnerRegrForecastAverage$new()
  tsk = mlr_tasks$get("airpassengers")
  learner$train(tsk)
  expect_prediction(learner$predict(tsk))
  forecast = learner$forecast(task = tsk, h = 10)
  expect_prediction_forecast(forecast)
})
