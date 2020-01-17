```
Feature Name: `Windowconversion`
Start Date: 2019-12-04
Target Date:
```


## Summary

 - function prototype for a windowconversion using lagged and lagged differenced values


## Motivation



To solve forecasting problems as a regression problems, reshaping the data to an appropriate format is essential. Supervised ML-Algorithms usually expect the data to be in a tabular format: one row euqals one observation. The transformation to such a structure is called window-conversion.

## Guide-level explanation



#### Example for a univariate forecasting problem

Consider the following timeseries-data:

```
data
        date target 
1 2019-11-29      1 
2 2019-11-30      2
3 2019-12-01      4
4 2019-12-02      4
5 2019-12-03      9
6 2019-12-04      6
.      .          .
.      .          .
.      .          .
```
One approach to forecast this series could be, to use two lagged values and the first difference of the series as features. (For the differences see https://www.rdocumentation.org/packages/base/versions/3.6.1/topics/diff )

The window conversion should be a function that creates additional columns for every lag and every lagged diffference we specified. 

```r
windowConversion(data, date.col="date", lag = c(1L,2L), diff.lag = c(1L), diff.diff = c(1L))

        date target target_lag_1 target_lag_2 target_lag_1_diff_1
1 2019-11-29      1           NA           NA         NA
2 2019-11-30      2            1           NA          1
3 2019-12-01      4            2            1          2
4 2019-12-02      4            4            2          0
5 2019-12-03      9            4            4          5
6 2019-12-04      6            9            4         -3
.      .          .            .            .          .
.      .          .            .            .          .
.      .          .            .            .          .
```


 

## Reference-level explanation

A prototype of the function for the window-conversion including lagged and lagged differenced features. This may be used as a basis for discussions.

```r
windowConversion = function(data, date.col = NULL, lag.cols = NULL, lag = 0L,
                            diff.cols=NULL, diff.lag=0L, diff.diff=0L){
  
  #... include some checks for dataformat
  
  setDT(data)
  if(is.null(date.col)){
    stop("date.col must be given")
  }
  assert_choice(date.col, colnames(data))
  assert_integerish(lag)
  assert_integerish(diff.lag)
  assert_integerish(diff.diff)
  assert_subset(lag.cols, colnames(data))
  assert_subset(diff.cols, colnames(data))
  # if not specified use all columns except the date column
  if(is.null(diff.cols)){
    diff.cols = setdiff((colnames(data)),date.col)
  }
  if(is.null(lag.cols)){
    lag.cols = setdiff((colnames(data)),date.col)
  }
  
  if(any(lag>0)){
    lag.names = do.call("paste", c(CJ(lag.cols,"lag", lag, sorted = FALSE), sep="_"))
    data[, c(lag.names) := shift(.SD, lag), .SDcols = lag.cols]
  }
  
  if(any(diff.lag)>0 | any(diff.diff>0)){
    #diff only accepts values > 0
    if(!any(diff.lag > 0)){
      diff.lag = 1
    }
    if(!any(diff.diff > 0)){
      diff.diff = 1
    }
    
    # helper function to adjust for the shorter output of diff() with NA padding
    padDiff = function(x, lag,diff){
      xx = diff(x,lag,diff)
      pad = rep(NA,length(x)-length(xx) )
      return(c(pad,xx))
    }
    
    #Combinations of lags and differences
    diff.selection = CJ(diff.lag,diff.diff)
    
    for(i in seq_len(nrow(diff.selection))){
      lag.val = diff.selection[[i,1]]
      diff.val = diff.selection[[i,2]]
      lagdiff.names = do.call("paste", c(CJ(diff.cols,"lag", lag.val,"diff",diff.val, sorted = FALSE),sep="_"))
      data[,c(lagdiff.names) := lapply(.SD,padDiff,lag.val,diff.val)  ,.SDcols = diff.cols ]
    }
  }
  return(data)
}

```



## Rationale, drawbacks and alternatives
[rationale-and-alternatives]: #rationale-and-alternatives
data.table currently has no function like diff() in base R, which makes getting the lagged differences kind of ugly.


## Prior art
[prior-art]: #prior-art

## Introduced Dependencies 
The above function relies on the following packages:

  - checkmate
  - data.table

## Unresolved questions
[unresolved-questions]: #unresolved-questions

