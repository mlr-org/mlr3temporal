context("LearnerArima")

# test_that("autotest", {
#   learner = LearnerRegrForecastArima$new()
#   expect_learner(learner)
#   result = run_autotest(learner)
#   expect_true(result, info = result$error)
# })

test_that("Basic Tests", {
  task = tsk("airpassengers")
  learner = lrn("forecast.arima")
  learner$train(task, 1:20)
  fitted_values = learner$fitted_values(row_ids = 5:10)
  expect_data_table(fitted_values, nrows = 6, ncols = length(task$target_names), types = "numeric")
  expect_prediction(learner$predict(task, 21:30))

  resampling = ResamplingCustom$new()
  resampling$instantiate(task, train_sets = list(1:100), test_sets = list(101:144))
  rr = resample(task, learner, resampling)
  expect_resample_result(rr)

  forecast = learner$forecast(task = task, h = 10, newdata = task$data(rows = 11:20, cols = "fdeaths"))
  expect_prediction_forecast(forecast)
})

test_that("Exogenous Variables", {
  task = TaskRegrForecast$new(id = "se", backend = tsbox:: ts_c(mdeaths, fdeaths), target = "mdeaths")
  learner = lrn("forecast.arima")
  learner$predict_type = "se"
  learner$train(task, 1:10)
  expect_prediction_forecast(learner$predict(task, 5:15))
})

test_that("Expected Errors", {
  learner = lrn("forecast.arima")
  task = tsk("airpassengers")
  expect_error(learner$train(task, c(1, 4, 6, 8, 9)), "consecutive row_ids")
  expect_error(learner$fitted_values(row_ids = 1:10), "Model has not been trained")
  learner$train(task, 1:20)
  expect_error(learner$fitted_values(row_ids = 19:22), "Model has not been trained on selected row_ids")
  expect_error(learner$predict(task, c(21, 13, 1)), "consecutive row_ids")
  expect_error(learner$predict(task, c(22:30)), "timesteps do not match")
})

test_that("two row, one col", {
  data = data.frame(target = rnorm(2))
  task = TaskRegrForecast$new(id = "two row, two col", backend = ts(data), target = "target")
  learner = lrn("forecast.arima")
  learner$train(task)
  expect_prediction(learner$predict(task))
})

test_that("five row, five col", {
  data = data.frame(target = rnorm(5), col2 = rnorm(5))
  task = TaskRegrForecast$new(id = "one row, two col", backend = ts(data), target = "target")
  learner = lrn("forecast.arima")
  learner$train(task)
  expect_prediction(learner$predict(task))
})
