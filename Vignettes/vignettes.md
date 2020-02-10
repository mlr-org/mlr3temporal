---
  title: "Forecasting time series in mlr3forecasting"
author: "Arshadipour"
output:
  rmarkdown::html_vignette:
  toc: true
vignette: >
  %\VignetteIndexEntry{ time series forecasting in mlr3}
%\VignetteEngine{knitr::rmarkdown}
%\VignetteEncoding{UTF-8}
---
  
  ```{r, include = FALSE}
knitr::opts_chunk$set(
  cache = FALSE,
  collapse = TRUE,
  comment = "#>"
)
```

##Installation
  
```{r setup}
set.seed(123)
install.packages("mlr3") ; install.packages("tsbox")
library(mlr3);library(tsbox)

```

Install the development version from GitHub:
  
remotes::install_github("mlr-org/mlr3forecasting")



This vignette is an introduction to performing time series forecasting in **mlr3forecasting**.




## Introduction 
Time sries analysis is a sub-field of supervised machine learning in which the aim is useing
prior time steps to predict the next time step. By using window conversion which reconstruct data, time series datasets turn into a supervised learning problem. It is possible to increase the width of window to include more previous time steps and it can be used for more than one observation at one time which called multivariate time series.


## Usage
Since the temporal data are not appropriate for the most machine learning algorithms, we need to reform data to the right shape
for machin learning algorithm.
Basically there are two major approaches to feed timeseries data into a regression method: the "rolling window"-approach and the
"expanding window"-approach. Both methods use the last k values as features to predict the next value(s) in the timeseries.

actually, the Lagged values of a timeseries can be used as features for a machine learning algorithm.


Another method for reshaping temporal data is windowconversion using lagged and lagged differenced values. Supervised ML-Algorithms 
usually expect the data to be in a tabular format: one row euqals one observation. The transformation to such a structure is called window-conversion.

```r
Data_ reformating = windowConversion(data, date.col="date", lag = c(1L,2L), diff.lag = c(1L), diff.diff = c(1L))

```

## Tasks

Task include an arbitrary identifier for the task, used in plots and summaries. Backend allows control over how data is accessed 
and the name of taget variable is used for calling during the regresion analysis.
For classification, the `TaskClassif` and for regression task `TaskRegr` has been used.


```{r}
# create learning task
task = TaskRegrForecast$new(id = "id",backend = "data set",target = "target variable")
print(task) # Gives a short summary of task
```

## Learner

Thare are two tzpe of learner
1- Auto.Arima Learner which is a LearnerRegrForecast for an (AR)I(MA) model implemented  in the  `forecast` package.

```{r}
# load learner and set hyperparameter
Learner_AutoArima  = LearnerRegrForecastAutoArima$new()

#set hyperpatameters
Learner_AutoArima$ParamInt$new$id = d
Learner_AutoArima$ParamInt$new$default = 5
Learner_AutoArima$ParamInt$new$lower = 0
```


2- Vector Autoregression Learner which is a LearnerRegrForecast for a vector autoregressive model implemented in th `var` package. 

```{r}
# load learner and set hyperparameter
Learner_AutoArima  = LearnerRegrForecastAutoArima$new()

#set hyperpatameters
Learner_AutoArima$ParamInt$new$id = lag.max
Learner_AutoArima$ParamInt$new$tags=train
Learner_AutoArima$ParamInt$new$lower = 1L
```


## train and predict

# train/test split
```{r}
train_set = sample(task$nrow, 0.8 * task$nrow)
test_set = setdiff(seq_len(task$nrow), train_set)
```
# train the model
```{r}
learner$train(task, row_ids = train_set)
```


# predict data
```{r}
prediction = learner$predict(task, row_ids = test_set)
```


## Resampling
```{r}
resampling = rsmp("cv", folds = 3L)
resample = resample(task_iris, learner, resampling)
resample$score(measure)
```

## Univariate Forecast Example
```{r}
load_task_AirPassengers = function(id = "airpassengers") {
  requireNamespace("datasets")
  b = as_data_backend.forecast(load_dataset("AirPassengers", "datasets"))
  task = TaskRegrForecast$new(id, b, target = "target")
  b$hash = task$man = "mlr3forecasting::mlr_tasks_airpassengers"
  return(task)
}
```


## Multivariate Forecast Example
```{r}
load_task_petrol = function(id = "petrol") {
  requireNamespace("fma")
  b = as_data_backend.forecast(fma::petrol)
  task = TaskRegrForecast$new(id, b, target = c("Chemicals", "Coal", "Petrol", "Vehicles"))
  b$hash = task$man = "mlr3forecasting::mlr_tasks_petrol"
  return(task)
}
```










