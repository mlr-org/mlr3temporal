context("DataBackendLong")

test_that("DataBackendLong construction", {
  data = tsbox::ts_dts(tsbox::ts_c(mdeath = tsbox::ts_dt(mdeaths), fdeath = tsbox::ts_dt(fdeaths)))
  self = backend = as_data_backend(data)
  private = private(self)
  #expect_backend(backend)


  rows = self$rownames
  cols = self$colnames

  dt2 = self$data(rows, cols)
  expect_data_table(dt2, nrows = 72, ncols = 3)
  #self$data(rows, cols[0])
  #self$data(rows[0], cols)
})
