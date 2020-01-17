test_that("has date.col", {

  task = tsk("AirPassengers")
  tc = task$time_col()
  assert_class(tc, "POSIXct")
  expect_equal(task$nrow, length(tc))

})
