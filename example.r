library(digest)
library(tsbox)
### Example univariate forecast

df = ts_c(mdeaths,fdeaths)
task = TaskRegrForecast$new(id = "a",backend =df,target = "mdeaths")
learner=LearnerRegrForecastAutoArima$new()
learner$train(task)
learner$model

### Example 2

task = tsk("AirPassengers")
learner=LearnerRegrForecastAutoArima$new()
learner$train(task)
learner$model


### Example multivariate forecasting
task = tsk("petrol")
learner =LearnerRegrForecastMultivVAR$new()
learner$train(task)
learner$model

