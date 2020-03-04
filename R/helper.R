# helper for confidence intervals to standard errors
ci_to_se = function(width, level){
  se = width / (2 * stats::qnorm(0.5 + level / 200))
  return(se)
}

# helper for standard errors to confidence intervals
se_to_ci = function(se, level){
  width = se * (2 * stats::qnorm(0.5 + level / 200))
  return(width)
}
