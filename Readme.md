  ## mlr3forecasting

This package provide prediction for mlr3

## Descreption
Time series forecasting is an important area of machine learning. It is important because there are so many prediction problems that involve a time component. However, while the time component adds additional information, it also makes time series problems more difficult to handle compared to many other prediction tasks. Here we will implement a time series forecasting model using machine learning workflow and then try to evaluate the model predictions. Based on workflow, datset will split into non-overlapping training and test sets and then We are interested in models (based on training set) for prediction( based on test set) using supervised learner. Evaluation will be done using resampling method for time series data.

![Overal overview of project ](https://github.com/mlr-org/mlr3forecasting/blob/Descreption/workflow.PNG)

  ## Installation
Before starting, install the following required packages:
```r
install.packages("mlr3") ; install.packages("tsbox")
library(mlr3);library(tsbox);
library(ggplot2)
library(forecast)
```
Then, install the development version from GitHub:
```r  
remotes::install_github("mlr-org/mlr3forecasting")
```
##  Tasks

| Name     | Code              | Type    |
| -------- | ----------------- | ------- |
| Regression   | `TaskRegrForecast("data")`  | TaskRegr |

## Learner

| Name     | Code              | Type    |
| -------- | ----------------- | ------- |
| Average Learner  | `LearnerForecastAverage$new()`  |Average Forecast|
| Auto.Arima Learner  | `LearnerRegrForecastAutoArima$new()`  | (AR)I(MA) model |
| Autoregression Learner | `LearnerRegrForecastVAR$new()`  | autoregressive model |

# train the model
```r
learner$train(task, row_ids = train_set)
```

# predict data
```r
prediction = learner$predict(task, row_ids = test_set)
prediction$response
prediction$se
```

## Resampling
 There are two methods of resampling:

1-Rolling Window Cross Validation Resampling which split data based on the folds. 
The paprameteres which used are Number of folds, size of rolling window, forecasting horizon in the test set and flag for the fixed sized window.

```r
resampling = rsmp("RollingWindowCV", folds = 3, fixed_window = FALSE)
resample = resample(task, learner, resampling)
resample$score(measure)
```

2-Holdout Resampling which split data into training and test data set based on the ratio parameter.

```r
resampling = rsmp("forecast.holdout", ratio = 0.5)
resample = resample(task, learner, resampling)
resample$score(measure)
```

## Univariate Forecast Example
```r
load_task_AirPassengers = function(id = "airpassengers") {
  requireNamespace("datasets")
  b = as_data_backend.forecast(load_dataset("AirPassengers", "datasets"))
  task = TaskRegrForecast$new(id, b, target = "target")
  b$hash = task$man = "mlr3forecasting::mlr_tasks_airpassengers"
  return(task)
}
```

## Multivariate Forecast Example
```r
load_task_petrol = function(id = "petrol") {
  requireNamespace("fma")
  b = as_data_backend.forecast(fma::petrol)
  task = TaskRegrForecast$new(id, b, target = c("Chemicals", "Coal", "Petrol", "Vehicles"))
  b$hash = task$man = "mlr3forecasting::mlr_tasks_petrol"
  return(task)
}
```
## Visualization

This package follows the {mlr3} idea  for visualisation and use the  `autoplot()` methods.
To show it, we need to use the resamplind method and task which used for prediction. 

```r
autoplot(object = resample, task= TaskRegrForecast )
```
## Contributing
We welcome contributions!! Please search before creating a new issue and then, Feel free to add related issues .
Forecasters try to take care to maintain the existing coding style.
You may also contribute in several ways like creating new features, fixing bugs, improving documentation and examples or translating any document to your language.

## More resources

https://mlr3book.mlr-org.com/

# References
https://towardsdatascience.com/an-overview-of-time-series-forecasting-models-a2fa7a358fcb

© 2020 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About
