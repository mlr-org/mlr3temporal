
```
 Feature Name: `Forecasting Reduction Techniques`
 Start Date: 2019-11-16
 Target Date:
 ```

## Summary
[summary]: #summary
 
 - Lagged values of a timeseries can be used as features for a machine learning algorithm.
 - Two major apporaches: rolling window regression and expanding window regression

## Motivation
[motivation]: #motivation

Most machine learning algorithms are not designed for temporal data. To still use these methods, we have to put the data in the right shape for our algorithm.


## Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

Basically there are two major approaches to feed timeseries data into a regression method: the "rolling window"-approach and the "expanding window"-approach. Both methods use past values as features to predict the next value(s) in the timeseries.

#### Rolling-window-approach
[Rolling-window-approach]: #Rolling-window-approach

The rolling window approach is the most obvius choice for reducing a forecasting problem to a ordinary regression problem, as it is easy to implement due to the fixed size of the feature dimension.

 Example for k = 2: Predict X(t) given X(t-1) and X(t-2)

```
   X(t) X(t-1) X(t-2)
1     1     NA     NA
2     2      1     NA
3     3      2      1
4     4      3      2
5     5      4      3
6     6      5      4
7     7      6      5
8     8      7      6
9     9      8      7
10   10      9      8

```

#### Expanding-window-approach
[Expanding-window-approach]: #Expanding-window-approach

The expanding-window-approach uses all the currently available data to predict the next value(s) of the series. This means at time t we have t-1 features to regress on. This approach may be useful, when there is only a short history of the data available.

Example: predict X(t) given all previous values of the series
```
  X(t) X(t-1) X(t-2) X(t-3) X(t-4)
1    1     NA     NA     NA     NA
2    2      1     NA     NA     NA
3    3      2      1     NA     NA
4    4      3      2      1     NA
5    5      4      3      2      1

```



## Rationale, drawbacks and alternatives
[rationale-and-alternatives]: #rationale-and-alternatives

These two approaches make it possible the reformulate time series forcasting as a regression problem.While training via the rolling window approach seems obvious, we have to come up with solutions for the expanding window approach, as most algorithms expect a fixed sized feature-dimensionality.

Supposed we we want to predict the next h values of our series we have h regression problems, one for each timestep we want to predict. Through this approach the algorithm may not be capable to take advantages of the correlation between our targets. Another drawback is the hurt iid assumption that is usually required for machine learning algorithms.

