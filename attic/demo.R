# import Data -------------------------------------------------------------


muc = read.csv("https://www.ncei.noaa.gov/data/global-summary-of-the-year/access/GM000004199.csv")
nyc = read.csv("https://www.ncei.noaa.gov/data/global-summary-of-the-year/access/USW00094728.csv")


muc_start = muc$DATE[1]
muc_end = muc$DATE[nrow(muc)]

nyc_start = nyc$DATE[1]
nyc_end = nyc$DATE[nrow(nyc)]

# keep information on station , temp and precipitation
muc = muc[, c("DATE", "PRCP", "TAVG", "TMIN", "TMAX")]
nyc = nyc[, c("PRCP", "TAVG", "TMIN", "TMAX")]


muc = na.omit(muc)
nyc = na.omit(nyc)



# model --------------------------------------------------------------------

task = TaskRegrForecast$new(id = "muc",
  backend = ts(muc, start = muc_start, end = muc_end, frequency = 1),
  target = c("TAVG", "TMIN", "TMAX"))

learner = LearnerRegrForecastVAR$new()
learner$train(task, row_ids = 1:130)
learner$model
p = learner$predict(task, row_ids = 131:136)

p$se

rr = rsmp("RollingWindowCV", fixed_window = F)
rr$instantiate(task)
resample = resample(task, learner, rr, store_models = TRUE)

resample$predictions()

autoplot(task)
task$col_roles


# autoarima ---------------------------------------------------------------

task = TaskRegrForecast$new(id = "muc",
  backend = ts(muc[c("TAVG", "PRCP")], start = muc_start, end = muc_end, frequency = 1),
  target = "TAVG")


learner = LearnerRegrForecastAutoArima$new()
learner$train(task, row_ids = 1:130)
learner$model
p = learner$predict(task, row_ids = 131:136)
p$se


checkresiduals(learner$model)

autoplot(forecast(learner$model, xreg = as.matrix(task$data(cols = "PRCP", rows = 131:136))))


# nyc ---------------------------------------------------------------------


task = TaskRegrForecast$new(id = "nyc",
  backend = ts(nyc, start = nyc_start, end = nyc_end, frequency = 1),
  target = c("TAVG", "TMIN", "TMAX"))

autoplot(task) + ggtitle("NYC - Yearly Climate Data")
