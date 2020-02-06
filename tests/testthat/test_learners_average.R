context("learners_average")

test_that("autotest", {
  learner = LearnerForecastAverage$new()
  expect_learner(learner)
  # result = run_autotest(learner) # FIXME: Forecasting needs its own autotest
  # expect_true(result, info = result$error)
})

test_that("Basic Tests", {
  learner = LearnerForecastAverage$new()
  tsk = mlr_tasks$get("airpassengers")
  learner$train(tsk)
  expect_prediction(learner$predict(tsk))

})
