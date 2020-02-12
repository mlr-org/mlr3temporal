library(digest)
library(tsbox)
### Example univariate forecast

df = ts_c(mdeaths,fdeaths)
task = TaskRegrForecast$new(id = "a",backend =df,target = "mdeaths")
learner=LearnerRegrForecastAutoArima$new()
learner$train(task, row_ids = 1:20)
learner$model
p=learner$predict(task, row_ids = 21:43)

### Example 2

task = tsk("airpassengers")
learner=LearnerForecastAverage$new()
learner$train(task,row_ids =  1:143)
learner$model
p=learner$predict(task,row_ids =14)

### Example multivariate forecasting
task = tsk("petrol")
learner =LearnerRegrForecastVAR$new()
learner$train(task, row_ids = 1:100 )
learner$model
p=learner$predict(task, row_ids = 101:150)
resampling = rsmp("forecast.holdout",ratio = 0.8)
resampling$instantiate(task)
rr = resample(task, learner, resampling, store_models = TRUE)
