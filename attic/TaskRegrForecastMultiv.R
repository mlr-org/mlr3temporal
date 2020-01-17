# #' @title Multivariate Forecast Regression Task
# #'
# #' @import data.table
# #' @import mlr3
# #'
# #' @usage NULL
# #' @format [R6::R6Class] object inheriting from [Task]/[TaskSupervised].
# #'
# #' @description
# #' This task specializes [Task] and [TaskSupervised] for multivariate forecasting regression problems.
# #' The target columns are assumed to be numeric.
# #' The `task_type` is set to `"regr"` `.

# #'
# #' @section Construction:
# #' ```
# #' t = TaskRegrForecast$new(id, backend, target, date.col)
# #' ```
# #'
# #' * `id` :: `character(1)`\cr
# #'   Identifier for the task.
# #'
# #' * `backend` :: [DataBackend]\cr
# #'   Either a [DataBackendLong], a object of class `ts` or a `data.frame` with specified date column
# #'
# #'
# #'     or any object which is convertible to a DataBackendLong with `as_data_backend()`.
# #'   E.g., a object of class  `dts` will be converted to a [DataBackendLong].
# #'
# #' * `target` :: `character()`\cr
# #'   Name of the target column.
# #'
# #' * `date.col` :: `character(1)`\cr
# #'   Name of the date column. Not needed if backend is a timeseries
# #'
# #' @section Fields:
# #' All methods from [TaskSupervised], and additionally:
# #'

# #' @section Methods:
# #' See [TaskSupervised] and [TaskRegr].
# #'
# #' @family Task
# #' @seealso
# #' @export
# # @examples
# #
# # # possible properties:
# # mlr3::mlr_reflections$task_properties$regr



# TaskRegrForecastMultiv = R6::R6Class("TaskRegrForecastMultiv",
#   inherit = TaskSupervised,
#   public = list(

#     initialize = function(id, backend, target, date.col=NULL) {

#       if(!is.null(date.col)&&is.data.frame(backend) ){
#         setDT(backend)
#         backend = (melt(backend,id.vars=date.col, variable.factor = FALSE))
#         backend$value = as.numeric(backend$value)
#       }else if ("ts" %in% class(backend)){
#         backend = ts_dts(backend)
#         if(ncol(backend)==2){
#           backend$id = target
#           attr(backend,"cname")$id ="id"
#           backend = ts_dts(backend)
#         }
#       }

#       super$initialize(id = id, backend = (backend), target = target, task_type="regr")

#       for(i in self$target_names){
#         type = self$col_info[id == i]$type
#         if (type %nin% c("integer", "numeric")) {
#           stopf("Target column '%s' must be numeric", i)
#         }
#       }

#     }
#   )
# )
