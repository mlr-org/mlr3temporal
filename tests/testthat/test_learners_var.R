context("Learner Var")

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
  fitted_values = learner$fitted_values(row_ids = 5:10)
  expect_data_table(fitted_values, nrows = 6, ncols = length(tsk$target_names), types = "numeric" )
  expect_prediction(learner$predict(tsk, 21:30))
  forecast = learner$forecast(task = tsk, h=10)
  expect_prediction(forecast)
  expect_equal(length(forecast$row_ids), 10)
})
