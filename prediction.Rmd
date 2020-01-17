---
title: "Prediction"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Current state 

Right now The Auto-arima predictions work like this:
 Each time learner$predict(row_ids = ids) is called the model assumes that ids are the timestamps that come directly after the last training instance (N). The forecasts are always done assuming the next step is N+1 and the number of steps is determindes by the length of ids. 

# How it should be

Instead of determining the horizon by the length of the testsamples, there should be an argument for this. For learner$predict(row_ids = 10:15, h=3) the following should be done:

1. check if the timestamp according to row 10 is the consecutive one of the last training instance.

2. make h = 3 predictions at timestep 10: 

| predicted Timestep        | Mean_prediction           | SE_prediction | other predictions   
| -------- |:--------:| ---:|---:|
| 10     | 1 | 0.1 |5 |
| 11     | 2      |   0.2 |   6 
| 12 | 3     |    0.3 |7 |
3. update the model for timestep 10 without refitting the parameters.

4. make h = 3 predictions for timestep 11

5. and so on 

In total, the call learner$predict(row_ids = 10:15, h=3) should produce 6 matrices with each h=3 rows. 






# Problems and solutions 

1. Add a new argument h to task\$truth() and learner\$predict_internal() that specifies the horizon, i.e task$truth(row_ids = 10:15, h=4) should get 6 matrices with 4 rows each. 

2. learner\$predict_internal() needs to update the model after the prediction for each row_id.

3. How do we want to handle the multiple matrices?
      - 3-dimensional array?
      - list of data.tables
