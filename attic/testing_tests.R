library(mlr3)
library(mlr3learners)

task = tsk("iris")
learner = lrn("classif.rpart")

N = 43
target = rnorm(N)
#data = cbind(data.table::data.table(target = target), generate_data(learner, N))
data = ts(target)
task = TaskForecast$new("proto", data, target = "target")
learner=LearnerRegrForecastAutoArima$new()
learner$train(task, row_ids = 1:20)
learner$model
p=learner$predict(task, row_ids = 21:43)
p



df = ts_c(mdeaths,fdeaths)
task = TaskRegrForecast$new(id = "a",backend = df,target = "mdeaths")
learner = LearnerRegrForecastAutoArima$new()
learner$train(task, row_ids = 1:20)
learner$model
p = learner$predict(task, row_ids = 21:43)


task = tsk("airpassengers")
learner=LearnerForecastAverage$new()
learner$train(task,row_ids =  1:143)
learner$model
p=learner$predict(task,row_ids =14)





task$feature_types
task$feature_names
