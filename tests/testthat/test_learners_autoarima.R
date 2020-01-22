test_that("is learner", {
  learner = LearnerRegrForecastAutoArima$new()
  expect_learner(learner)
})
