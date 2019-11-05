```
Feature Name: `do_something`
Start Date: 2019-11-04
Target Date:
```

## Summary
[summary]: #summary

Add method foo and bar, this allows to baz.

## Motivation
[motivation]: #motivation

We need baz in order to foo. This can also be longer and more
verbose.

## Guide-level explanation
[guide-level-explanation]: #guide-level-explanation

Sometimes, when applying a forecasting method, what occurs is ...

Example: 
```r
foo = 1
bar = 2
do_something(foo, bar)
```

I propose to change this to bar, as this would ...


## Reference-level explanation
[reference-level-explanation]: #reference-level-explanation

Internally, the function would look the following:

Example: 
```r
do_something = function(a, b) {
  ...
}
```


## Rationale, drawbacks and alternatives
[rationale-and-alternatives]: #rationale-and-alternatives

This design seems fairly obvious choice in the design space.
The main alternative to this proposal is not to implement it,
and let users to calculate joined subslices from indexes or pointers.

## Prior art
[prior-art]: #prior-art

There exists a function that implements the API as here...


## Unresolved questions
[unresolved-questions]: #unresolved-questions