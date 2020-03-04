library(digest)
library(tsbox)
### Example univariate forecast
df = ts_c(mdeaths, fdeaths)

task = TaskRegrForecast$new(id = "forecast", backend = df, target = "mdeaths")
learner = LearnerRegrForecastAutoArima$new()
learner$predict_type = "se"
learner$predict_types
learner$train(task, row_ids = c(1:3))
learner$model
p = learner$predict(task, row_ids = 22:30)
p$score(msr("forecast.mae"))
autoplot(task)

### Example 2

task = tsk("airpassengers")
learner = LearnerRegrForecastAverage$new()
learner$train(task,row_ids = 1:20)
learner$model
p = learner$predict(task,row_ids = 21:55)
p$score(msr("forecast.mae"))

### Example multivariate forecasting
task = tsk("petrol")
learner = LearnerRegrForecastVAR$new()
learner$predict_type = "se"
learner$train(task, row_ids = 1:16 )
learner$model
p = learner$predict(task, row_ids = 17:28)
p$score(msr("forecast.mae"))
rr = rsmp("forecast.holdout")
rr$instantiate(task)
resample = resample(task, learner, rr, store_models = TRUE)

autoplot(task)


d = fma::petrol
task = TaskRegrForecast$new(id = "a",backend = d,target = c("Coal","Chemicals"))
learner = LearnerRegrForecastVAR$new()
learner$predict_type = "se"
learner$train(task, row_ids = 1:16 )
learner$model
p = learner$predict(task, row_ids = 17:28)
