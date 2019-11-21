```
Feature Name: `DataBackendForecasting`
Start Date: 2019-11-04
Target Date:
```

## Summary
[summary]: #summary

Add a mlr3 DataBackend that can store one or multiple time-series.

## Motivation
[motivation]: #motivation

Storing time-series data is not trivial, as many possible formats exist. 
Data formats can either be *long* or *wide*, and the time-series could be stored as 
different data types.

Used formats: 
- Basic: `ts`: Example `r data(Airpassengers)`
- Advanced: `xts`: [Cheatsheet](https://www.datacamp.com/community/blog/r-xts-cheat-sheet) from library(xts)
- More general: `prophet` expects a `data.frame` with a `ds` (`as.Date`) and `y` (value) column.
- Very important: How was this solved in the old `mlr`?

Way more other formats exist, there is also a package that converts time-series formats around:
[tsbox](https://github.com/christophsax/tsbox)
This has another helpfull resource: [link](https://github.com/christophsax/tsbox)

## Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

Different forecasting methods require the data to be stored in different formats.
It is imperative to store data in a format that is flexible enough for different scenarios:

1. one or more time-series
2. time-series can be equi-distant or  not
3. time-series can be measured at equivalent grids.


Example: 

```r
# Equi-distant and same grid:
ts1 = ts(rnorm(12), frequency = 4, start = 2000)
ts2 = ts(rnorm(12), frequency = 4, start = 2000)
# Different grid
ts1 = ts(rnorm(12), frequency = 4, start = 2000)
ts2 = ts(rnorm(36), frequency = 12, start = 2000)
```


Proposals:

(Long Format): From `tsbox`: 

```
 In data frames, multiple time series will be stored in a 'long'
     format. tsbox detects a _value_, a _time_ and zero to several _id_
     columns. Column detection is done in the following order:

       1. Starting *on the right*, the first first ‘numeric’ or
          ‘integer’ column is used as *value column*.

       2. Using the remaining columns, and starting on the right again,
          the first ‘Date’, ‘POSIXct’, ‘numeric’ or ‘character’ column
          is used as *time column*. ‘character’ strings are parsed by
          ‘anytime::anytime()’. The time stamp, ‘time’, indicates the
          beginning of a period.

       3. *All remaining* columns are *id columns*. Each unique
          combination of id columns points to a time series.

```
This would look as follows (output is a data.table):
```
> ts_dt(x.ts)
          id       time value
  1: mdeaths 1974-01-01  2134
  2: mdeaths 1974-02-01  1863
  3: mdeaths 1974-03-01  1877
  4: mdeaths 1974-04-01  1877
  5: mdeaths 1974-05-01  1492
 ---                         
140: fdeaths 1979-08-01   379
141: fdeaths 1979-09-01   393
142: fdeaths 1979-10-01   411
143: fdeaths 1979-11-01   487
144: fdeaths 1979-12-01   574
```


## Reference-level explanation
[reference-level-explanation]: #reference-level-explanation

@mllg created a draft for a `DataBackend`.

```r
DataBackendLong = R6Class("DataBackendLong",
  inherit = mlr3::DataBackend,
  cloneable = FALSE,

  public = list(
    id_col = NULL,
    value_col = NULL,

    initialize = function(data, primary_key, id_col) {
      assert_data_frame(data, ncol = 3L, col.names = "unique")
      setDT(data)
      super$initialize(data, primary_key, data_formats = "data.table")

      self$id_col = assert_choice(id_col, names(data))
      self$value_col = setdiff(colnames(data), c(primary_key, id_col))
      setkeyv(data, c(primary_key, id_col))
    },

    data = function(rows, cols, data_format = "data.table", roll = TRUE) {
      assert_atomic_vector(rows)
      assert_names(cols, type = "unique")
      assert_choice(data_format, self$data_formats)
      cols = intersect(cols, self$colnames)

      data = private$.data[CJ(rows, setdiff(cols, self$primary_key)), roll = roll]
      if (nrow(data) == 0L) {
        if (setequal("time", cols)) {
          private$.data[list(rows), self$primary_key, on = self$primary_key, with = FALSE][[1]]
        } else {
          cbind(
            as.data.table(named_list(setdiff(cols, self$primary_key), vector(typeof(private$.data$value)))))
          # FIXME ....
        }
      } else {
        dcast(data, formulate(self$primary_key, self$id_col))
      }
    },

    head = function(n = 6L) {
      rn = head(self$rownames, n)
      cn = self$colnames
      self$data(rn, cn)
    },

    distinct = function(rows, cols, na_rm = TRUE) {
      assert_names(cols, type = "unique")
      assert_flag(na_rm)
      cols = intersect(cols, self$colnames)

      tab = private$.data[CJ(rows, cols), list(N = uniqueN(self$value_col, na.rm = na_rm)), by = c(self$id_col)]
      set_names(tab[["N"]], tab[[self$id_col]])
    },

    missings = function(rows, cols) {
      assert_atomic_vector(rows)
      assert_names(cols, type = "unique")
      cols = intersect(cols, self$colnames)

      private$.data[CJ(rows, cols), list(N = sum(is.na(self$value_col))), by = c(self$id_col)]
      set_names(tab[["N"]], tab[[self$id_col]])
    }
  ),

  active = list(
    rownames = function() {
      unique(private$.data[, self$primary_key, with = FALSE])[[1L]]
    },

    colnames = function() {
      c(self$primary_key, unique(private$.data[, self$id_col, with = FALSE])[[1L]])
    },

    nrow = function() {
      uniqueN(private$.data, by = self$primary_key)
    },

    ncol = function() {
      uniqueN(private$.data, by = self$id_col) + 1L
    }
  ),

  private = list(
    .calculate_hash = function() {
      digest(list(self$data, self$primary_key, self$value_col), algo = "xxhash64")
    }
  )
)

#' @export
as_data_backend.dts = function(data) {
  cname = attr(data, "cname")
  set(data, j = cname$time, value = as.IDate(data[[cname$time]]))
  DataBackendLong$new(data, primary_key = cname$time, id_col = cname$id)
}

#' @export
as_data_backend.forecast = function(data) {
  require_namespaces("tsbox")
  as_data_backend(tsbox::ts_dts(data))
}
```


## Rationale, drawbacks and alternatives
[rationale-and-alternatives]: #rationale-and-alternatives

The current design is by no means obvious, but it  is simple enough to be implemented
as a first approach.

Adherence to design principles: 
- [x] simple 
- [x] no or few depencies
- [x] extensible

- In the future we might want to capture a larger set of applications, similar to python's sktime.
  The current proposal might not be extensive enough.
- The main alternatives are listed above, but we might not know enough about the problems we want to solve
  to focus on a specific alternative.
- Converters from one format to another can be worked out if required.

## Prior art
[prior-art]: #prior-art

Alternatives and different approaches are implemented in many different packages, notably sktime, xts, tsibble etc.


## Unresolved questions
[unresolved-questions]: #unresolved-questions

Is / does this: 
- A new task type?
- Need new backend?
- Solve 95% of forecasting data situations?
  - Forecasting a single time-series
  - Forecasting with covariates
  - Forecasting multiple time-series
