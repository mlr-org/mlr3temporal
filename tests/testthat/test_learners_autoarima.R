context("LearnerAutoArima")

test_that("autotest", {
  learner = LearnerRegrForecastAutoArima$new()
  expect_learner(learner)
  result = run_autotest(learner)
  expect_true(result, info = result$error)
})

test_that("Basic Tests", {
  learner = LearnerRegrForecastAutoArima$new()
  tsk = mlr_tasks$get("airpassengers")
  learner$train(tsk, 1:20)
  fitted_values = learner$fitted_values(row_ids = 5:10)
  expect_data_table(fitted_values, nrows = 6, ncols = length(tsk$target_names), types = "numeric" )
  expect_prediction(learner$predict(tsk, 21:30))
  forecast = learner$forecast(task = tsk, h=10)
  expect_prediction(forecast)
  expect_equal(length(forecast$row_ids), 10)
  rs = ResamplingCustom$new()
  rs$instantiate(tsk, train_sets = list(1:100), test_sets = list(101:144))
  res = resample(tsk, learner, rs)
  res$prediction()
  # expect_resample_result(res) scoring currently broken, see https://github.com/mlr-org/mlr3measures/issues/7
})
