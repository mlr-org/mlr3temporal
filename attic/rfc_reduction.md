
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



Basically there are two major approaches to feed timeseries data into a regression method: the "rolling window"-approach and the "expanding window"-approach. Both methods use the last k values as features to predict the next value(s) in the timeseries.

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
The difference between these two approaches is the amount of data that is used for making the prediction. While the rolling window (with window size n) approach uses the last n values for training and then predicts the next values, the expanding window approach trains the model before every prediction on all the available data.

Example: Suppose we are at timestep 50 of a timeseries

Rolling window approach:

1. choose a window-size (for simplicity we choose 50)
2. train the model on observation 1 to 50
3. predict the value for timestep 51
4. for the next prediction train the model on observation 2 to 51
5. predict the value for timestep 52 
6. repeat according to this scheme

Expanding window approach:

1. use all the available data to train the model (timesteps 1 to 50)
2. predict the value for timestep 51
1. use all the available data to train the model (timesteps 1 to 51)
4. predict the value for timestep 52 
5. repeat according to this scheme



## Rationale, drawbacks and alternatives
[rationale-and-alternatives]: #rationale-and-alternatives

The main drawback of this two approaches are the hurt iid assumptions that are usually required for machine learning algorithms. Another point is how we want to handle multi-step ahead forecasts, as there are several options to do that.
