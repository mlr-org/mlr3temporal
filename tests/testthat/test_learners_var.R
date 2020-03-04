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
  expect_prediction_forecast(p)

  rr = rsmp("forecastHoldout")
  rr$instantiate(task)
  res = resample(task, learner, rr, store_models = TRUE)
  res$prediction()
  expect_resample_result(res)
  forecast = learner$forecast(task = task, h = 10, new_data = task$data(rows = 11:20, cols = "fdeaths"))
  expect_prediction_forecast(forecast)
})

test_that("Exogenous Variables", {
  backend = fma::petrol
  tsk = TaskRegrForecast$new(id = "ex", backend = backend, target = c("Chemicals", "Coal"))
  learner = LearnerRegrForecastVAR$new()
  learner$predict_type = "se"
  learner$train(tsk, row_ids = 1:10 )
  p = learner$predict(tsk, row_ids = 7:15)
  expect_prediction_forecast(p)
})

