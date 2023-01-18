# helper for confidence intervals to standard errors
ci_to_se = function(width, level) {
  width / (2 * stats::qnorm(0.5 + level / 200))
}

# helper for standard errors to confidence intervals
se_to_ci = function(se, level) {
  se * (2 * stats::qnorm(0.5 + level / 200))
}

# Takes timestamps from specified column and converts to long format
 df_to_backend = function(data, target, date_col) {
   setDT(data)
   assert_choice(date_col, names(data))
   assert_subset(target, names(data))
   assert_data_table(data[, setdiff(names(data), date_col), with = FALSE], types = "numeric")

   backend = melt(data, id.vars = date_col, variable.factor = FALSE, variable.name = "id")
   backend$value = as.numeric(backend$value)
   backend[[date_col]] = as.POSIXct(backend[[date_col]])
   backend
 }
