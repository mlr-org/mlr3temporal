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

  rr = rsmp("forecastHoldout")
  rr$instantiate(task)
  res = resample(task, learner, rr, store_models = TRUE)
  res$prediction()
  expect_resample_result(res)
})

test_that("Exogenous Variables", {
  backend = fma::petrol
  tsk = TaskRegrForecast$new(id = "ex", backend = backend, target = c("Chemicals", "Coal"))
  learner = LearnerRegrForecastVAR$new()
  learner$train(task, row_ids = 1:10 )
  p = learner$predict(task, row_ids = 7:15)
  expect_prediction(p)
  forecast = learner$forecast(task = tsk, h = 10, new_data = tsk$data(rows = 12:21, cols = tsk$feature_names))
  expect_prediction(forecast)
  expect_equal(length(forecast$row_ids), 10)

})

