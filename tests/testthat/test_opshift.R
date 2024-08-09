library("mlr3")
library("mlr3pipelines")
library("mlr3temporal")
devtools::load_all()
bb = as.data.frame(fma::petrol)
bb$dates = lubridate::date_decimal(as.numeric(time(fma::petrol)))
task = TaskRegrForecast$new("petrol", bb, target = c("Chemicals"), date_col = "dates")
pop = po("shift", min = 1, max = 2)

task$data()
foo = pop$train(list(task))
pop$state$bc
foo$output$col_info

