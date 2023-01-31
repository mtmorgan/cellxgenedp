test_that("collections() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    collections <- collections()
    expect_true(nrow(collections) >= 48L)
    COLLECTIONS_COLUMNS <- c(
        collection_id="character", access_type="character",
        contact_email="character",
        contact_name="character",
        curator_name="character",
        data_submission_policy_version="character",
        description="character", links="list",
        name="character", visibility="character",
        created_at="Date", published_at="Date",
        updated_at="Date"
    )
    column_names <- names(COLLECTIONS_COLUMNS)
    expect_true(all(column_names %in% names(collections)))
    classes <- vapply(collections[column_names], class, character(1))
    expect_identical(classes, COLLECTIONS_COLUMNS)
})
