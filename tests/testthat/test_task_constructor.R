
# Issue #68

test_that("sp500", {
    require_namespaces("datasets")
    data = fma::petrol
    task = TaskForecast$new(
        id = 'petrol',
        backend = data,
        target = 'Vehicles'
    )
    expect_task(task)


    # Long Data Table
    dt = ts_data.table(data)
    task2 = TaskForecast$new(
        id = 'petrol',
        backend = ts_wide(dt),
        target = 'Vehicles',
        date_col = "time"
    )
    expect_task(task2)

    dtw = ts_wide(dt)

    # Wide Data Table
    task3 = TaskForecast$new(
        id = 'petrol',
        backend = dtw,
        target = 'Vehicles',
        date_col = "time"
    )
    expect_task(task3)
})

