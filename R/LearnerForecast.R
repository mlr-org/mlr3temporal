#' @title LearnerForecast
#'
#' @name LearnerForecast
#'
#' @description
#' This Learner specializes [Learner] for forecasting problems:
#'
#' * `task_type` is set to `"forecast"`.
#' * Creates [Prediction]s of class [PredictionForecast].
#' * Possible values for `predict_types` are:
#'   - `"response"`: Predicts a numeric response for each observation in the test set.
#'   - `"se"`: Predicts the standard error for each value of response for each observation in the test set.
#'   - `"distr"`: Probability distribution as `VectorDistribution` object (requires package `distr6`, available via
#'     repository \url{https://raphaels1.r-universe.dev}).
#'
#' @template param_id
#' @template param_param_set
#' @template param_predict_types
#' @template param_feature_types
#' @template param_learner_properties
#' @template param_data_formats
#' @template param_packages
#' @template param_man
#'
#' @template seealso_learner
#' @export
#' @template example
LearnerForecast = R6Class("LearnerForecast",
  inherit = Learner,

  public = list(

    #' @field date_span (named `list()`)\cr
    #' Stores the beginning and end of the date span of the training data.
    date_span = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(id,
                          param_set = ps(),
                          predict_types = "response",
                          feature_types = character(),
                          properties = character(),
                          data_formats = "data.table",
                          packages = character(),
                          man = NA_character_) {
      super$initialize(
        id = id,
        task_type = "forecast",
        param_set = param_set,
        feature_types = feature_types,
        predict_types = predict_types,
        properties = properties,
        data_formats = data_formats,
        packages = packages,
        man = man
      )
    },

    #' @description
    #' Train the learner on a set of observations of the provided `task`.
    #' Mutates the learner by reference, i.e. stores the model alongside other information in field `$state`.
    #'
    #' @param task ([Task]).
    #'
    #' @param row_ids (`integer()`)\cr
    #'   Vector of training indices as subset of `task$row_ids`.
    #'   For a simple split into training and test set, see [partition()].
    #'
    #' @return
    #' Returns the object itself, but modified **by reference**.
    #' You need to explicitly `$clone()` the object beforehand if you want to keeps
    #' the object in its previous state.
    train = function(task, row_ids = NULL) {
      if (is.null(row_ids)) {
        row_ids = task$row_ids
      }
      row_ids = sort(row_ids)
      if (!test_set_equal(row_ids, min(row_ids):max(row_ids))) {
        stop("Model needs to be trained on consecutive row_ids.")
      }
      super$train(task, row_ids)
    },

    #' @description
    #' Uses the information stored during `$train()` in `$state` to create a new [Prediction]
    #' for a set of observations of the provided `task`.
    #'
    #' @param task ([Task]).
    #'
    #' @param row_ids (`integer()`)\cr
    #'   Vector of test indices as subset of `task$row_ids`.
    #'   For a simple split into training and test set, see [partition()].
    #'
    #' @return [Prediction].
    predict = function(task, row_ids = NULL) {
      if (is.null(row_ids)) {
        row_ids = task$row_ids
      }
      row_ids = sort(row_ids)
      if (!test_set_equal(row_ids, min(row_ids):max(row_ids))) {
        stop("Predictions can only be made on consecutive row_ids")
      }
      if (min(row_ids) > self$date_span$end$row_id + 1) {
        stop("Predicted timesteps do not match the requested timesteps.")
      }
      super$predict(task, row_ids)
    },

    #' @description
    #' Returns the fitted values of the model, i.e. the values that the model predicted for the training data.
    #'
    #' @param row_ids (`integer()`)\cr
    #'   Vector of test indices as subset of `task$row_ids`.
    #'   For a simple split into training and test set, see [partition()].
    #'
    #' @return [data.table::data.table()] .
    fitted_values = function(row_ids = self$date_span$begin$row_id:self$date_span$end$row_id) {
      assert_row_ids(row_ids)
      if (is.null(self$model)) {
        stop("Model has not been trained yet")
      }
      if (!test_subset(row_ids, self$date_span$begin$row_id:self$date_span$end$row_id)) {
        stop("Model has not been trained on selected row_ids")
      }
      n.row = self$date_span$end$row_id - self$date_span$begin$row_id + 1
      fitted = as.data.table(stats::fitted(self$model))
      fitted[, colnames(fitted) := lapply(.SD, function(x) as.numeric(x))]
      n = n.row - nrow(fitted)
      fitted = rbind(
        as.data.table(
          sapply(names(fitted), function(x) rep(NA, n), simplify = FALSE)
        ),
        fitted
      )
      fitted[row_ids - self$date_span$begin$row_id + 1, ]
    }
  )
)
