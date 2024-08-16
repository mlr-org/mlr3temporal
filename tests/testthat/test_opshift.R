library(mlr3)
library(mlr3pipelines)
library(mlr3learners)
library(mlr3tuning)
library(mlr3filters)
library(paradox)
library(data.table)
devtools::load_all()
bb = as.data.frame(fma::petrol)
bb$dates = lubridate::date_decimal(as.numeric(time(fma::petrol)))
task = TaskRegrForecast$new("petrol", bb, target = c("Chemicals"), date_col = "dates")
lag = po("shift", min = 1, max = 2)


# Define the BoxCox transformation pipeline
boxcox = po("boxcox", param_vals = list(lower = -Inf, upper=Inf))

# Define the rpart learner
learner = lrn("regr.rpart")

# Combine them into a GraphLearner pipeline
graph = lag %>>% learner
graph_learner = GraphLearner$new(graph)

# Define the search space for tuning
param_set = ParamSet$new(params = list())

# Define the tuning instance
tuning_instance = TuningInstanceSingleCrit$new(
  task = task,
  learner = graph_learner,
  resampling = rsmp("cv", folds = 5),
  measure = msr("regr.mse"),
  search_space = param_set,
  terminator = trm("evals", n_evals = 50)
)

# Choose a tuner (Random Search in this case)
tuner = tnr("random_search")

# Run the tuning
tuner$optimize(tuning_instance)

# Get the best performing parameters
best_params = tuning_instance$result_learner_param_vals
print(best_params)

# Train the learner with the best parameters
graph_learner$param_set$values = best_params
graph_learner$train(task)
