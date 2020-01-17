
```
 Feature Name: `Forecasting Reduction Techniques`
 Start Date: 2019-11-16
 Target Date:
 ```

## Summary
[summary]: #summary
 
 - Rolling window based regression is a technique to reduce a timeseries forecasting problem to a ordinary regression problem

 - Lagged values of the timeseries are used as features to set up a supervised learning problem.
 
 - Several options fot multistep ahead predictions 

## Motivation
[motivation]: #motivation

Most machine learning algorithms are not designed for temporal data. To still use these methods, we have to reshape the data for our algorithm.


## Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

Rolling window regression is a simple approach to feed timeseries data into a regression algorithm. This method uses the last k values of a series as input-features to predict the next value in the timeseries.

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

Once the data is reshaped into such a tabular format, the forecasting problem can be treated as an ordinary regression problem and all the supervised methods can be used to learn a mapping between past values X(t-1), ..., X(t-k) and the current value X(t) of the series.


## Multi-step-forecasting
[Multi-step-forecasting]: #Multi-step-forecasting

For multi-step-forecasts there are several options to tackle the problem.

##### 1. Direct forecasting
[1.Direct-forecasting]: #1.Direct-forecasting

For the direct forecasting method you build a seperate model for each timestep you want to predict.

 - prediction(t+1) = model1(x(t), x(t-1),..., x(t-n))
 - prediction(t+2) = model2(x(t), x(t-1),..., x(t-n))
 - etc.
 
An alternative to this approach is building a multi-output regression model that can handle the forecasts directly without the need for additional models.
 
##### 2. Recursive forecasting
[2.Recursive-forecasting]: #2.Recursive-forecasting
 
For the recursive forecasting method you build one model and predict timestep t+1. To forecast the next value (t+2) you feed this prediction back into the model.

 - prediction(t+1) = model1(x(t), x(t-1),..., x(t-n))
 - prediction(t+2) = model1(prediction(t+1), x(t), x(t-1),..., x(t-n-1))
 - etc.
 
##### 3. Hybrid forecasting
[3.Hybrid-forecasting]: #3.Hybrid-forecasting

It would also be possible to combine the two strategies: build a seperate model for each timestep, but feed the prediction of the previous timestep as input.

 - prediction(t+1) = model1(x(t), x(t-1),..., x(t-n))
 - prediction(t+2) = model2(prediction(t+1), x(t), x(t-1),..., x(t-n-1))
 - etc.


The difficulty for these methods comes with handling the dataformat. As for the direct approach this is still rather easy, as we would only have to create several targets, things get more comlicated for the recursive and the hybrid method: We have different features for every timestep we want to predict.



## Reference-level explanation
[reference-level-explanation]: #reference-level-explanation


## Rationale, drawbacks and alternatives
[rationale-and-alternatives]: #rationale-and-alternatives

The main drawback of this two approaches are the hurt iid assumptions that are usually required for machine learning algorithms and especially model selection via cross validation. Another point is how we want to handle multi-step ahead forecasts, as there are several options to do that.

## Prior art
[prior-art]: #prior-art

## Introduced Dependencies 


## Unresolved questions
[unresolved-questions]: #unresolved-questions
