```
Feature Name: `forecasting_methods`
Start Date: 2019-12-04
Target Date:
```

## Summary
[summary]: #summary

Add learners for forecasting methods

## Motivation
[motivation]: #motivation

We need learners for forecasting methods in order to train and predict forecasting models.

## Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

Sometimes, when applying a forecasting method, what occurs is ...

Example: 
```r
l = LearnerForecast$new(id = "my_id", some_parameter = 0.5)

l$train(task, row_ids = train_set)

prediction = l
$predict(task, row_ids = test_set)

```



## Reference-level explanation
[reference-level-explanation]: #reference-level-explanation

Internally, the function would look the following:

Example: 
```r

LearnerForecast = R6::R6Class("LearnerForecast",
                                        inherit = Learner,
                                        public = list(
                                          initialize = function(id = "forecast") {
                                            super$initialize(
                                              id = id,
                                              param_set = ParamSet$new(),
                                              predict_types = ,
                                              feature_types = ,
                                              properties = ,
                                              packages = ,
                                            )
                                          },
                                          
                                          train = function(task) {
                                            
                                          },
                                          predict = function(task) {
                                            
                                          }
                                        )
)

```


## Rationale, drawbacks and alternatives
[rationale-and-alternatives]: #rationale-and-alternatives

This design seems fairly obvious choice in the design space.
The main alternative to this proposal is not to implement it,
and let users to calculate joined subslices from indexes or pointers.

## Prior art
[prior-art]: #prior-art

There exists a function that implements the API as here...

## Introduced Dependencies 
This solution would introduce dependencies on the following (additional) packages:

Those packages either depend on or import the following other (additional) packages:

Using this package would allow us to ... instead of re-implementing and maintining
N loc ourselves.


## Unresolved questions
[unresolved-questions]: #unresolved-questions
