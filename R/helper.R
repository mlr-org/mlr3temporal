
# Expansion of base::difftime for months
time.frequency = function(time) {
  diff = diff(time)
  diff.unique = unique(diff)
  attr(diff.unique, "units") = attr(diff,"units")
  if(length(diff.unique) == 1){
    return(diff.unique)
  }
  time = as.POSIXlt(time)
  months = time$year*12 + time$mon
  diff.months = unique(diff(months))
  if(length(diff.months) == 1){
    attr(diff.months, "units") = "months"
    return(diff.months)
  }
  return(diff.unique)
}


# helper for confidence intervals to standard errors
ci_to_se = function(width, level){
  se = width / (2 * stats::qnorm(0.5 + level / 200))
  return(se)
}
