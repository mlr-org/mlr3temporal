library(digest)
library(tsbox)
library(ggplot2)
### Example univariate forecast

df = ts_c(mdeaths,fdeaths)
task = TaskRegrForecast$new(id = "a", backend = df, target = "mdeaths")
learner = LearnerRegrForecastAutoArima$new()
learner$train(task, row_ids = 1:20)
learner$model
p = learner$predict(task, row_ids = 21:43)

class(task)
autoplot(task)

### Example 2

task = tsk("airpassengers")
learner = LearnerForecastAverage$new()
learner$train(task,row_ids = 1:143)
learner$model
p = learner$predict(task,row_ids = 144)
learner$train(task)
p = learner$predict(task)

learner$

### Example multivariate forecasting
task = tsk("petrol")
learner = LearnerRegrForecastVAR$new()
learner$train(task, row_ids = 1:100 )
learner$model
p = learner$predict(task, row_ids = 101:150)
rr = rsmp("RollingWindowCV", fixed_window = F)
rr$instantiate(task)
resample = resample(task, learner, rr, store_models = TRUE)




