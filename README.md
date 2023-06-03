
# mlr3temporal

Temporal prediction / forecasting for mlr3

<!-- badges: start -->

[![r-cmd-check](https://github.com/mlr-org/mlr3temporal/actions/workflows/r-cmd-check.yml/badge.svg)](https://github.com/mlr-org/mlr3temporal/actions/workflows/r-cmd-check.yml)
[![CRAN Status
Badge](https://www.r-pkg.org/badges/version-ago/mlr3temporal)](https://cran.r-project.org/package=mlr3temporal)
[![codecov](https://codecov.io/gh/mlr-org/mlr3temporal/branch/master/graph/badge.svg)](https://codecov.io/gh/mlr-org/mlr3temporal)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![StackOverflow](https://img.shields.io/badge/stackoverflow-mlr3-orange.svg)](https://stackoverflow.com/questions/tagged/mlr3)
<!-- badges: end -->

Time series analysis accounts for the fact that data points taken over
time may have an internal structure (such as autocorrelation, trend or
seasonal variation) that should be accounted for. This package extends
the [mlr3](https://github.com/mlr-org/mlr3) package framework by
time-series prediction and resampling methods.

![](man/figures/multi_timeseries.png)<!-- -->

## Installation

Install the development version from GitHub:

``` r
remotes::install_github("mlr-org/mlr3temporal")
```

## Forecasting

Currently the following methods are implemented:

### Tasks

| Id                                                                                       | Code                   | Type                    |
|------------------------------------------------------------------------------------------|------------------------|-------------------------|
| [airpassengers](https://mlr3temporal.mlr-org.com/reference/mlr_tasks_airpassengers.html) | `tsk("airpassengers")` | Univariate Timeseries   |
| [petrol](https://mlr3temporal.mlr-org.com/reference/mlr_tasks_petrol.html)               | `tsk("petrol")`        | Multivariate Timeseries |

### Learners

| Id                                                                                                  | Learner               | Package                                                 |
|-----------------------------------------------------------------------------------------------------|-----------------------|---------------------------------------------------------|
| [forecast.auto_arima](https://mlr3temporal.mlr-org.com/reference/mlr_learners_regr.auto_arima.html) | Auto Arima            | [forecast](https://cran.r-project.org/package=forecast) |
| [forecast.arima](https://mlr3temporal.mlr-org.com/reference/mlr_learners_regr.arima.html)           | Arima                 | [forecast](https://cran.r-project.org/package=forecast) |
| [forecast.average](https://mlr3temporal.mlr-org.com/reference/mlr_learners_regr.average.html)       | Average               | base                                                    |
| [forecast.VAR](https://mlr3temporal.mlr-org.com/reference/mlr_learners_regr.VAR.html)               | Vector Autoregression | [vars](https://cran.r-project.org/package=vars)         |

### Measures

| Id                                                                                          | Measure                        | Package |
|---------------------------------------------------------------------------------------------|--------------------------------|---------|
| [forecast.mae](https://mlr3temporal.mlr-org.com/reference/mlr_measures_forecast.mae.html)   | Mean Absolute Error            | base    |
| [forecast.mape](https://mlr3temporal.mlr-org.com/reference/mlr_measures_forecast.mape.html) | Mean Absolute Percentage Error | base    |
| [forecast.mse](https://mlr3temporal.mlr-org.com/reference/mlr_measures_forecast.mse.html)   | Mean Squared Error             | base    |
| [forecast.rmse](https://mlr3temporal.mlr-org.com/reference/mlr_measures_forecast.rmse.html) | Root Mean Squared Error        | base    |

### Resampling Methods

| Id                                                                                                   | Resampling                     | Package |
|------------------------------------------------------------------------------------------------------|--------------------------------|---------|
| [forecast_holdout](https://mlr3temporal.mlr-org.com/reference/mlr_resamplings_forecast_holdout.html) | Holdout                        | base    |
| [forecast_cv](https://mlr3temporal.mlr-org.com/reference/mlr_resamplings_forecast_cv.html)           | Rolling Window CrossValidation | base    |

## Code Example

``` r
library(mlr3temporal)

task = tsk("airpassengers")
learner = lrn("forecast.auto_arima")
learner$train(task, row_ids = 1:20)
predictions = learner$predict(task, row_ids = 21:55)
measure = msr("forecast.mae")
predictions$score(measure)
autoplot(task)
```

## Resampling

#### Holdout

Split data into a training set and a test set. Parameter `ratio`
determines the ratio of observation going into the training set
(default: 2/3).

``` r
task = tsk("petrol")
learner = lrn("forecast.VAR")
resampling = rsmp("forecast_holdout", ratio = 0.8)
rr = resample(task, learner, resampling, store_models = TRUE)
rr$aggregate(msr("forecast.mae"))
```

#### Rolling Window CV

Splits data using a `folds`-folds (default: 10 folds) rolling window
cross-validation.

``` r
task = tsk("petrol")
learner = lrn("forecast.VAR")
resampling = rsmp("forecast_cv", folds = 5, fixed_window = FALSE)
rr = resample(task, learner, resampling, store_models = TRUE)
rr$aggregate(msr("forecast.mae"))
```

## More resources

For detailed information on how to get started with `mlr3` please read
the [mlr3 book](https://mlr3book.mlr-org.com/) and consult the
[Vignette](https://mlr3temporal.mlr-org.com/articles/vignettes.html) for
more examples of mlr3temporal.

## Contributing to mlr3temporal

Please consult the [wiki](https://github.com/mlr-org/mlr3/wiki/) for a
[style guide](https://github.com/mlr-org/mlr3/wiki/Style-Guide), a
[roxygen guide](https://github.com/mlr-org/mlr3/wiki/Roxygen-Guide) and
a [pull request
guide](https://github.com/mlr-org/mlr3/wiki/PR-Guidelines).
