context("learners_autoarima")

test_that("autotest", {
  learner = LearnerRegrForecastAutoArima$new()
  expect_learner(learner)
  # result = run_autotest(learner) # FIXME: Forecasting needs its own autotest
  # expect_true(result, info = result$error)
})

test_that("Basic Tests", {
  learner = LearnerRegrForecastAutoArima$new()
  tsk = mlr_tasks$get("airpassengers")
  learner$train(tsk, 1:20)
  expect_prediction(learner$predict(tsk, 21:30))

  rs = ResamplingCustom$new()
  rs$instantiate(tsk, train_sets = list(1:100), test_sets = list(101:144))
  res = resample(tsk, learner, rs)
  res$prediction()
  # expect_resample_result(res) scoring currently broken, see https://github.com/mlr-org/mlr3measures/issues/7
})
