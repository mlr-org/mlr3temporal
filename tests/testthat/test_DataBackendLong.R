context("DataBackendLong")

test_that("DataBackendLong construction", {
  data = tsbox::ts_dts(tsbox::ts_c(mdeath = tsbox::ts_dt(mdeaths), fdeath = tsbox::ts_dt(fdeaths)))
  self = backend = as_data_backend(data)
  private = private(self)
  expect_backend(backend)


  rows = self$rownames
  cols = self$colnames

  self$data(rows, cols)
  self$data(rows, cols[0])
  self$data(rows[0], cols)
})
