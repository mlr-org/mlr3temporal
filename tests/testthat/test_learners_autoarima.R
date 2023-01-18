context("LearnerAutoArima")

# test_that("autotest", {
#   learner = LearnerRegrForecastAutoArima$new()
#   expect_learner(learner)
#   result = run_autotest(learner)
#   expect_true(result, info = result$error)
# })

test_that("Basic Tests", {
  learner = LearnerRegrForecastAutoArima$new()
  tsk = mlr_tasks$get("airpassengers")
  learner$train(tsk, 1:20)
  fitted_values = learner$fitted_values(row_ids = 5:10)
  expect_data_table(fitted_values, nrows = 6, ncols = length(tsk$target_names), types = "numeric" )
  expect_prediction(learner$predict(tsk, 21:30))
  rs = ResamplingCustom$new()
  rs$instantiate(tsk, train_sets = list(1:100), test_sets = list(101:144))
  res = resample(tsk, learner, rs)
  res$predictions()
  expect_resample_result(res)
  forecast = learner$forecast(task = tsk, h = 10, new_data = tsk$data(rows = 11:20, cols = "fdeaths"))
  expect_prediction_forecast(forecast)
})


test_that("Exogenous Variables",{
  tsk = TaskRegrForecast$new(id = "se", backend = tsbox:: ts_c(mdeaths, fdeaths), target = "mdeaths")
  learner = lrn("forecast.auto_arima")
  learner$predict_type = "se"
  learner$train(tsk, 1:10)
  expect_prediction_forecast(learner$predict(tsk, 5:15))
})

test_that("Expected Errors",{
  learner = LearnerRegrForecastAutoArima$new()
  tsk = mlr_tasks$get("airpassengers")
  expect_error(learner$train(tsk, c(1,4,6,8,9)), "consecutive row_ids")
  expect_error(learner$fitted_values(row_ids = 1:10), "Model has not been trained")
  learner$train(tsk, 1:20)
  expect_error(learner$fitted_values(row_ids = 19:22), "Model has not been trained on selected row_ids")
  expect_error(learner$predict(tsk, c(21, 13, 1)), "consecutive row_ids")
  expect_error(learner$predict(tsk, c(22:30)), "timesteps do not match")
})

test_that("one row, one col", {
  data = data.table(target = 4)
  task = TaskRegrForecast$new(id = "one row, one col", backend = ts(data), target = "target")
  learner = LearnerRegrForecastAutoArima$new()
  learner$train(task)
  expect_prediction(learner$predict(task))
})

test_that("one row, two col", {
  data = data.frame(target = rnorm(1), col2 = rnorm(1))
  task = TaskRegrForecast$new(id = "one row, two col", backend = ts(data), target = "target")
  learner = LearnerRegrForecastAutoArima$new()
  learner$train(task)
  expect_prediction(learner$predict(task))
})

test_that("two row, one col", {
  data = data.frame(target = rnorm(2))
  task = TaskRegrForecast$new(id = "two row, two col", backend = ts(data), target = "target")
  learner = LearnerRegrForecastAutoArima$new()
  learner$train(task)
  expect_prediction(learner$predict(task))
})
