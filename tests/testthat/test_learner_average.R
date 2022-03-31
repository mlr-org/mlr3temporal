context("learners_average")

# test_that("autotest", {
#   learner = LearnerRegrForecastAverage$new()
#   expect_learner(learner)
#   result = run_autotest(learner)
#   expect_true(result, info = result$error)
# })

test_that("Basic Tests", {
  learner = LearnerRegrForecastAverage$new()
  tsk = mlr_tasks$get("airpassengers")
  learner$train(tsk)
  expect_prediction(learner$predict(tsk))
})

test_that("one row, one col", {
  data = data.table(target = 4)
  task = TaskRegrForecast$new(id = "one row, one col", backend = ts(data), target = "target")
  learner = LearnerRegrForecastAverage$new()
  learner$train(task)
  expect_prediction(learner$predict(task))
})

test_that("two row, one col", {
  data = data.frame(target = rnorm(2))
  task = TaskRegrForecast$new(id = "two row, two col", backend = ts(data), target = "target")
  learner = LearnerRegrForecastAverage$new()
  learner$train(task)
  expect_prediction(learner$predict(task))
})
