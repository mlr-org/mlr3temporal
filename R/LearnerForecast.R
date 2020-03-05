#' @title LearnerForecast
#'
#' @usage NULL
#' @name LearnerForecast
#' @format [R6::R6Class] inheriting from [mlr3::LearnerRegr].
#'
#' @section Construction:
#' ```
#' LearnerForecast$new()
#' ```
#'
#' @description
#' A LearnerForecast for for learner objects like [LearnerRegr].
#'
#'
#' Learners are build around the three following key parts:
#'
#' * Methods `$train()` and `$predict()` which call internal methods.
#' * A [paradox::ParamSet] which stores meta-information about available hyperparameters, and also stores hyperparameter settings.
#' * Meta-information about the requirements and capabilities of the learner.
#' * The fitted model stored in field `$model`, available after calling `$train()`.
#'
#' More classification and regression learners are implemented in the add-on package \CRANpkg{mlr3learners}.
#' More (experimental) learners can be found on GitHub: \url{https://github.com/mlr3forecasting/}.
#' A guide on how to extend \CRANpkg{mlr3} with custom learners can be found in the [mlr3book](https://mlr3book.mlr-org.com).
#'
#' @template seealso_learner
#' @export
LearnerForecast = R6Class("LearnerForecast", inherit = Learner,
  public = list(
    date_span = NULL,
    initialize = function(id, param_set = ParamSet$new(), predict_types = "response",
      feature_types = character(), properties = character(), data_formats = "data.table",
      packages = character(), man = NA_character_) {
      super$initialize(id = id, task_type = "forecast", param_set = param_set, feature_types = feature_types,
        predict_types = predict_types, properties = properties, data_formats = data_formats, packages = packages, man = man)
      },

    train = function(task, row_ids = NULL) {
      if(is.null(row_ids)){
        row_ids = task$row_ids
      }
      row_ids = sort(row_ids)
      if(!test_set_equal(row_ids, min(row_ids):max(row_ids))){
        stop("Model needs to be trained on consecutive row_ids.")
      }
      super$train(task, row_ids)
    },

    predict = function(task, row_ids = NULL) {
      if(is.null(row_ids)){
        row_ids = task$row_ids
      }
      row_ids = sort(row_ids)
      if(!test_set_equal(row_ids, min(row_ids):max(row_ids))){
        stop("Predictions can only be made on consecutive row_ids")
      }
      if(min(row_ids) > self$date_span$end$row_id + 1 ){
        stop("Predicted timesteps do not match the requested timesteps.")
      }
      super$predict(task, row_ids)
    },

    fitted_values = function(row_ids = self$date_span$begin$row_id : self$date_span$end$row_id){
      assert_row_ids(row_ids)
      if(is.null(self$model)){
        stop("Model has not been trained yet")
      }
      if(!test_subset(row_ids,self$date_span$begin$row_id:self$date_span$end$row_id)){
        stop("Model has not been trained on selected row_ids")
      }
      n.row = self$date_span$end$row_id - self$date_span$begin$row_id + 1
      fitted = as.data.table(stats::fitted(self$model))
      fitted[, colnames(fitted) := lapply(.SD ,function(x) as.numeric(x))]
      n = n.row-nrow(fitted)
      fitted = rbind(
        as.data.table(
          sapply(names(fitted), function(x) rep(NA,n), simplify = FALSE)
        ),
        fitted
      )

      fitted[row_ids - self$date_span$begin$row_id + 1,]

    }
  )
)
