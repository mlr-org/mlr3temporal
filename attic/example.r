library(digest)
library(tsbox)
### Example univariate forecast
df = ts_c(mdeaths, fdeaths)

task = TaskRegrForecast$new(id = "forecast", backend = df)
learner = LearnerRegrForecastAutoArima$new()
learner$train(task, row_ids = 1:20)
learner$model
p = learner$predict(task, row_ids = 21:30)
p$score(msr("forecast.mae"))
autoplot(task)

### Example 2

task = tsk("airpassengers")
learner = LearnerForecastAverage$new()
learner$train(task,row_ids = 1:100)
learner$model
p = learner$predict(task,row_ids = 101:122)
p$score(msr("forecast.mae"))

### Example multivariate forecasting
task = tsk("petrol")
learner = LearnerRegrForecastVAR$new()
learner$train(task, row_ids = 1:6 )
learner$model
p = learner$predict(task, row_ids = 7:11)
p$score(msr("forecast.mae"))
rr = rsmp("forecast.holdout")
rr$instantiate(task)
resample = resample(task, learner, rr, store_models = TRUE)

autoplot(task)


learner = LearnerRegrForecastAutoArima$new()
tsk = mlr_tasks$get("airpassengers")
learner$train(tsk, 1:40)
print(learner)
p = learner$predict(tsk, 1:50)
expect_prediction(learner$predict(tsk, 1:50))



task = tsk("airpassengers")
df = ts_c(mdeaths, fdeaths)

#task = TaskRegrForecast$new(id = "forecast", backend = df,target = "mdeaths")
learner = LearnerRegrForecastAutoArima$new()
learner$train(task,row_ids = 1:96)
learner$model
p = learner$predict(task,row_ids = 97:144)
rr = rsmp("forecast.holdout")
rr$instantiate(task)
resample = resample(task, learner, rr, store_models = TRUE)
