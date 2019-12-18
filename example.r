library(digest)
library(tsbox)
####### Example for tabular data with time column
x = arima.sim(list(order = c(1,0,3), ar = 0.99,ma=c(1,1,0.3)), n = 50)
xreg = rnorm(50)
x=(x+xreg)
time = Sys.Date() +1:50
df = data.table("x"=(x), "xreg"=(xreg),"time" = time)
task = TaskRegrForecast$new(id = "a",backend =df,target = "x",date.col = "time")


learner=LearnerAutoArima$new()
learner$param_set$values = list(d=0)
cv_train = function(task,h=5){
  row_ids = list()
  for(i in 3:(task$nrow-h)){
    row_ids[[i-2]] = task$row_ids[1:i]
  }
  return(row_ids)
}
cv_test = function(task,h=5){
  row_ids = list()
  for(i in 3:(task$nrow-h)){
    row_ids[[i-2]] = task$row_ids[(i+1):(i+h)]
  }
  return(row_ids)
}

resampling = rsmp("custom")
resampling$instantiate(task,
                       train = cv_train(task,h=5),
                       test = cv_test(task,h=5)
)


rr = resample(task,learner,resampling)


####### Example for timeseries data
df=ts_c(mdeaths,fdeaths)
task = TaskRegrForecast$new(id = "a",backend =df,target = "mdeaths")


learner=LearnerAutoArima$new()
learner$train(task,row_ids = task$row_ids[1:10])
pred = learner$predict(task,row_ids = task$row_ids[11:30 ])

cv_train = function(task,h=5){
  row_ids = list()
  for(i in 3:(task$nrow-h)){
    row_ids[[i-2]] = task$row_ids[1:i]
  }
  return(row_ids)
}
cv_test = function(task,h=5){
  row_ids = list()
  for(i in 3:(task$nrow-h)){
    row_ids[[i-2]] = task$row_ids[(i+1):(i+h)]
  }
  return(row_ids)
}

resampling = rsmp("custom")
resampling$instantiate(task,
                       train = cv_train(task,h=5),
                       test = cv_test(task,h=5)
)


rr = resample(task,learner,resampling)


