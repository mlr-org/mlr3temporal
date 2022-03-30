library(digest)
library(tsbox)
### Example univariate forecast
df = ts_c(mdeaths, fdeaths)

task = TaskRegrForecast$new(id = "forecast", backend = df, target = "fdeaths")

learner = LearnerRegrForecastAutoArima$new()
learner$predict_type = "se"
learner$predict_types
learner$train(task, row_ids = 1:21)
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
rr = rsmp("forecastHoldout")
rr$instantiate(task)
resample = resample(task, learner, rr, store_models = TRUE)
autoplot(task)


## Construction from data.frame
data = data.frame(a = runif(1:100), b = runif(1:100), t = Sys.time() + 1:100)
task = TaskRegrForecast$new(id = "df", backend = data, target = c("a","b"), date_col = "t")
l = LearnerRegrForecastVAR$new()
l$train(task)
l$predict(task)
d = mdeaths





