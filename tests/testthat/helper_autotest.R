# # # Learner autotest suite
# # #
# # # `run_experiment(task, learner)` runs a single experiment.
# # # Returns a list with success flag "status" (`logical(1)`),
# # # "experiment" (partially constructed experiment), and "error"
# # # (informative error message).
# # #
# # # `run_autotest(learner)` generates multiple tasks, depending on the properties of the learner.
# # # and tests the learner on each task, with each predict type.
# # # To debug, simply run `result = run_autotest(learner)` and proceed with investigating
# # # the task, learner and prediction of the returned `result`.
# # #
# # # NB: Extension packages need to specialize the S3 methods in the file.


# # generate_generic_tasks = function(learner, proto) {
# #   tasks = list()
# #   if (length(proto$feature_names) > 1L) {
# #     # individual tasks with each supported feature type
# #     for (ftype in learner$feature_types) {
# #       #choose only first
# #       sel = proto$feature_types[ftype, "id", on = "type", with = FALSE][[1L]][1]
# #       tasks[[sprintf("feat_single_%s", ftype)]] = proto$clone()$select(sel)
# #     }
# #   }


# #   # task with all supported features types
# #   sel = proto$feature_types[list(learner$feature_types), "id", on = "type", with = FALSE][[1L]]

# #   tasks$feat_all = proto$clone()$select(sel)

# #   # # task with missing values
# #   # if ("missings" %in% learner$properties) {
# #   #   # one missing val in each feature
# #   #   features = proto$feature_names
# #   #   rows = sample(proto$nrow, length(features))
# #   #   data = proto$data(cols = features)
# #   #   for (j in seq_along(features))
# #   #     data.table::set(data, rows[j], features[j], NA)
# #   #   tasks$missings = proto$clone()$select(character())$cbind(data)
# #   #
# #   #   # no row with no missing -> complete.cases() won't help
# #   #   features = sample(features, proto$nrow, replace = TRUE)
# #   #   data = proto$data(cols = proto$feature_names)
# #   #   for (i in seq_along(features))
# #   #     data.table::set(data, i = i, j = features[i], NA)
# #   #   tasks$missings_each_row = proto$clone()$select(character())$cbind(data)
# #   # }

# #   # task with weights
# #   if ("weights" %in% learner$properties) {
# #     tasks$weights = proto$clone()$cbind(data.frame(weights = runif(proto$nrow)))$set_col_role("weights", "weight", exclusive = TRUE)
# #   }


# #   # task univariate

# #   #learner var
# #   # if ("VAR" %in% learner$id) {
# #   #   #remove single variable
# #   #   tasks = tasks[!grepl("single", names(tasks))]
# #   # }


# #   # make sure that task ids match list names
# #   mlr3misc::imap(tasks, function(x, n) { x$id = n; x })
# # }

# # generate_data = function(learner, N) {
# #   generate_feature = function(type) {
# #     switch(type,
# #            logical = sample(rep_len(c(TRUE, FALSE), N)),
# #            integer = sample(rep_len(1:3, N)),
# #            numeric = runif(N),
# #            character = sample(rep_len(letters[1:2], N)),
# #            factor = sample(factor(rep_len(c("f1", "f2"), N), levels = c("f1", "f2"))),
# #            ordered = sample(ordered(rep_len(c("o1", "o2"), N), levels = c("o1", "o2")))
# #     )
# #   }
# #   types = unique(learner$feature_types)
# #   do.call(data.table::data.table, mlr3misc::set_names(mlr3misc::map(types, generate_feature), types))
# # }

# # #' @title Generate Tasks for a Learner
# # #'
# # #' @description
# # #' Generates multiple tasks for a given [Learner], based on its properties.
# # #' This function is primarily used for unit tests, but can also assist while
# # #' writing custom learners.
# # #'
# # #' @param learner :: [Learner].
# # #' @param N :: `integer(1)`\cr
# # #'   Number of rows of generated tasks.
# # #'
# # #' @return (List of [Task]s).
# # #' @keywords internal
# # #' @export
# # #' @examples
# # #' tasks = generate_tasks(lrn("classif.rpart"))
# # #' tasks$missings_binary$data()
# # generate_tasks = function(learner, N = 30L) {
# #   N = checkmate::assert_int(N, lower = 10L, coerce = TRUE)
# #   UseMethod("generate_tasks")
# # }

# generate_tasks.LearnerForecast = function(learner, N = 30L) {

#   exo1 = NULL
#   exo2 = NULL

#   if ("exogenous" %in% learner$properties) {
#     exo1 = generate_data(learner, N)
#     exo2 = generate_data(learner, N)
#     colnames(exo2) = paste0(colnames(exo2), 2)
#   }

#   if ("multivariate" %in% learner$properties) {
#     target1 = rnorm(N)
#     target2 = rnorm(N)
#     target3 = rnorm(N)
#     targets = data.table::data.table(target1, target2, target3)
#     tar_names = colnames(targets)
#     data = cbind(targets, exo1, exo2)

#   } else {
#     target = rnorm(N)
#     targets = data.table::data.table(target)
#     tar_names = colnames(targets)
#     data = cbind(targets, exo1, exo2)

#   }
#   task = TaskRegrForecast$new("proto", ts(data), target = tar_names)
#   data = data.table(target = rnorm(100))
#   task = TaskRegr$new("proto", data, target = tar_names)
#   tasks = generate_generic_tasks(learner, task)

#   # # generate sanity task
#   # with_seed(100, {
#   #
#   #   data = data.table::data.table(x = c(rnorm(100, 0, 1), rnorm(100, 10, 1)), y = c(rep(0, 100), rep(1, 100)))
#   #   data$unimportant = runif(nrow(data))
#   # })
#   # if ("multivariate" %in% learner$properties) {
#   #   task = mlr3misc::set_names(list(TaskForecast$new("sanity", ts(data), target = colnames(data))), "sanity")
#   # } else {
#   #   task = mlr3misc::set_names(list(TaskForecast$new("sanity", ts(data), target = "y")), "sanity")
#   #
#   # }
#   # task = mlr3misc::set_names(list(TaskForecast$new("sanity", ts(data), target = colnames(data))), "sanity")
#   # tasks = c(tasks, task)
#   tasks
# }
# registerS3method("generate_tasks", "LearnerForecast", generate_tasks.LearnerForecast)




# sanity_check = function(prediction) {
#   UseMethod("sanity_check")
# }



# sanity_check.PredictionRegr = function(prediction) {
#   prediction$score(mlr3::msr("regr.mse")) <= 1
# }
# registerS3method("sanity_check", "LearnerRegr", sanity_check.PredictionRegr)

# run_experiment = function(task, learner) {

#   err = function(info, ...) {
#     info = sprintf(info, ...)
#     list(
#       ok = FALSE,
#       task = task, learner = learner, prediction = prediction,
#       error = sprintf("[%s] learner '%s' on task '%s' failed: %s",
#                       stage, learner$id, task$id, info)
#     )
#   }


#   mlr3::assert_task(task)
#   learner = mlr3::assert_learner(mlr3::as_learner(learner, clone = TRUE), task = task)
#   prediction = NULL
#   learner$encapsulate = c(train = "evaluate", predict = "evaluate")


#   stage = "train()"
#   ok = try(learner$train(task), silent = TRUE)
#   if (inherits(ok, "try-error"))
#     return(err(as.character(ok)))
#   log = learner$log[stage == "train"]
#   if ("error" %in% log$class)
#     return(err("train log has errors: %s", mlr3misc::str_collapse(log[class == "error", msg])))
#   if (is.null(learner$model))
#     return(err("model is NULL"))

#   stage = "predict()"
#   prediction = try(learner$predict(task), silent = TRUE)
#   if (inherits(prediction, "try-error"))
#     return(err(as.character(prediction)))
#   log = learner$log[stage == "predict"]
#   if ("error" %in% log$class)
#     return(err("predict log has errors: %s", mlr3misc::str_collapse(log[class == "error", msg])))
#   msg = checkmate::check_class(prediction, "Prediction")
#   if (!isTRUE(msg))
#     return(err(msg))
#   if (prediction$task_type != learner$task_type)
#     return(err("learner and prediction have different task_type"))

#   allowed_types = mlr3::mlr_reflections$learner_predict_types[[learner$task_type]][[learner$predict_type]]
#   msg = checkmate::check_subset(prediction$predict_types, allowed_types, empty.ok = FALSE)
#   if (!isTRUE(msg))
#     return(err(msg))

#   msg = checkmate::check_subset(learner$predict_type, prediction$predict_types, empty.ok = FALSE)
#   if (!isTRUE(msg))
#     return(err(msg))

#   stage = "score()"
#   perf = try(prediction$score(mlr3::default_measures(learner$task_type)), silent = TRUE)
#   if (inherits(perf, "try-error"))
#     return(err(as.character(perf)))
#   msg = checkmate::check_numeric(perf, any.missing = FALSE)
#   if (!isTRUE(msg))
#     return(err(msg))
# #
# #   # run sanity check on sanity task
# #   if (grepl("^sanity", task$id) && !sanity_check(prediction)) {
# #     return(err("sanity check failed"))
# #   }

#   if (grepl("^feat_all", task$id) && "importance" %in% learner$properties) {
#     importance = learner$importance()
#     msg = checkmate::check_numeric(rev(importance), any.missing = FALSE, min.len = 1L, sorted = TRUE)
#     if (!isTRUE(msg))
#       return(err(msg))
#     msg = check_subsetpattern(names(importance), task$feature_names)
#     if (!isTRUE(msg))
#       return(err(msg))
#     if ("unimportant" %in% head(names(importance), 1L))
#       return(err("unimportant feature is important"))
#   }

#   if (grepl("^feat_all", task$id) && "selected_features" %in% learner$properties) {
#     selected = learner$selected_features()
#     msg = check_subsetpattern(selected, task$feature_names)
#     if (!isTRUE(msg))
#       return(err(msg))
#   }

#   if (grepl("^feat_all", task$id) && "oob_error" %in% learner$properties) {
#     err = learner$oob_error()
#     msg = checkmate::check_number(err)
#     if (!isTRUE(msg))
#       return(err(msg))
#   }

#   return(list(ok = TRUE, learner = learner, prediction = prediction, error = character()))
# }

# run_autotest = function(learner, N = 30L, exclude = NULL, predict_types = learner$predict_types) {

#   learner = learner$clone(deep = TRUE)
#   id = learner$id

#   tasks = generate_tasks(learner, N = N)
#   if (!is.null(exclude))
#     tasks = tasks[!grepl(exclude, names(tasks))]


#   for (task in tasks) {
#     for (predict_type in predict_types) {
#       learner$id = sprintf("%s:%s", id, predict_type)
#       learner$predict_type = predict_type

#       run = run_experiment(task, learner)
#       if (!run$ok)
#         return(run)
#     }
#   }

#   return(TRUE)
# }


