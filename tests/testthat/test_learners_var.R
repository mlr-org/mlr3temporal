context("Learner Var")

# test_that("autotest VAR", {
#   learner = LearnerRegrForecastVAR$new()
#   expect_learner(learner)
#   result = run_autotest(learner, exclude = "single")
#   expect_true(result, info = result$error)
# })

test_that("Basic Tests", {
  task = tsk("petrol")
  learner = LearnerRegrForecastVAR$new()
  learner$train(task, row_ids = 1:10 )
  p = learner$predict(task, row_ids = 7:15)
  expect_prediction_forecast(p)

  rr = rsmp("forecast_holdout")
  rr$instantiate(task)
  res = resample(task, learner, rr, store_models = TRUE)
  res$prediction()
  expect_resample_result(res)
  forecast = learner$forecast(task = task, h = 10, new_data = task$data(rows = 11:20, cols = task$feature_names))
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

test_that("needs exogenous or multivariare", {
  data = data.table(target = 4)
  task = TaskRegrForecast$new(id = "one row, one col", backend = ts(data), target = "target")
  learner = LearnerRegrForecastVAR$new()
  expect_error(learner$train(task))
})

test_that("one row, two col, if var fails, train fails", {
  data = data.frame(target = rnorm(1), col2 = rnorm(1))
  task = TaskRegrForecast$new(id = "one row, two col", backend = ts(data), target = c("target", "col2"))
  learner = LearnerRegrForecastVAR$new()

  test = try(VAR(data), silent = TRUE)
  if (inherits(test, "try-error")) {
    expect_error(learner$train(task))
  }
})
