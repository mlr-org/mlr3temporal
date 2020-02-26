LearnerForecast = R6Class("LearnerForecast", inherit = Learner,
  public = list(
    date_span = NULL,
    date_frequency = NULL,
    initialize = function(id, param_set = ParamSet$new(), predict_types = "response",
      feature_types = character(), properties = character(), data_formats = "data.table",
      packages = character(), man = NA_character_) {
      super$initialize(id = id, task_type = "forecast", param_set = param_set, feature_types = feature_types,
        predict_types = predict_types, properties = properties, data_formats = data_formats, packages = packages, man = man)
      },

    train = function(task, row_ids = NULL) {
      print(row_ids)
      if(is.null(row_ids)){
        row_ids = task$row_ids
      }
      row_ids = sort(row_ids)
      if(!test_set_equal(row_ids, min(row_ids):max(row_ids))){
        stop("Model needs to be trained on consecutive row_ids.")
      }
      print("a")
      print(row_ids)
      super$train(task, row_ids)
      span = range(task$date(row_ids)[[task$date_col]])
      self$date_span =
        list(begin=list(time = span[1], row_id = head(row_ids,1)), end = list(time = span[2], row_id = tail(row_ids,1)))
      self$date_frequency = time.frequency(task$date(row_ids)[[task$date_col]])

      if(length(self$date_frequency)>1){
        warning("The timestamps are not equidistant.")
      }
    },

    predict = function(task, row_ids = NULL) {
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
     # if(!test_subset(row_ids,self$date_span$begin$row_id:self$date_span$end$row_id)){
      #  stop("Model has not been trained on selected row_ids")
      #}
      n.row = self$date_span$end$row_id - self$date_span$begin$row_id + 1
      fitted = as.data.table(stats::fitted(self$model))
      nn = n.row-nrow(fitted)
    #  print(fitted)
     # print(self$model$y)
      #print(self$date_span)
      #print(nn)
      fitted = rbind(
        as.data.table(
          sapply(names(fitted), function(x) rep(NA,nn), simplify = FALSE)
        ),
        fitted
      )
      if(ncol(fitted)==1){
        colnames(fitted) = learner$state$train_task$target_names
      }
      fitted[row_ids - self$date_span$begin$row_id + 1]

    }
  )
)
