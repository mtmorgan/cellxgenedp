test_that("db() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    db <- db()
    expect_s3_class(db, c("cellxgene_db", "character"))
    expect_true(nzchar(db))
    json <- jsonlite::parse_json(db)
    expect_type(json, "list")
    expect_true(length(json) >= 48L)
})
