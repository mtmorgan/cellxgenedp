test_that("keys() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    keys <- keys()
    expected <- c(collections = 16L, datasets = 28L, files = 9L)
    expect_true(all(lengths(keys) >= expected))
})
