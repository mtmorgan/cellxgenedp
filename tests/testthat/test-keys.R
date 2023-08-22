test_that("keys() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    keys <- keys()
    expected <- c(collections = 18L, datasets = 23L, files = 3L)
    expect_true(all(lengths(keys) >= expected))
})
