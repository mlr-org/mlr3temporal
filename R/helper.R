# helper for confidence intervals to standard errors
ci_to_se = function(width, level) {
  width / (2 * stats::qnorm(0.5 + level / 200))
}

# helper for standard errors to confidence intervals
se_to_ci = function(se, level) {
  se * (2 * stats::qnorm(0.5 + level / 200))
}

