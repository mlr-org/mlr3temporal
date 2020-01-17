

tsk = mlr_tasks$get("iris")

tsk$head()
tsk$missings()
tsk$nrow
tsk$col_info


library(tsbox)
library(mlr3)
library(data.table)
df = ts_dts(ts_c(fdeaths, mdeaths))
db = as_data_backend(df)

db$data(rows = 1, cols = "fdeaths")

library(paradox)
ParamSet$new(list(ParamDbl$new("lambda", lower = 0, upper = Inf, default = 10^-3)))

tsk = TaskRegrForecast$new("deaths", backend = db, target = "value")
