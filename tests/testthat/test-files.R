test_that("files() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    files <- files()

    FILES_COLUMNS <- c(
        file_id="character", dataset_id="character", filename="character", 
        filetype="character", s3_uri="character", type="character", 
        user_submitted="logical", created_at="Date", updated_at="Date"
    )
    column_names <- names(FILES_COLUMNS)
    expect_true(all(column_names %in% names(files)))
    columns <- vapply(files[column_names], class, character(1))
    expect_identical(columns, FILES_COLUMNS)
})

test_that("files_download() works", {
    ## mockery does not appear to support applying two stubs to one function
    skip("files_download() not tested due to mockery limitation")
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    files <- files() |> head(2)
    mockery::stub(
        files_download,
        ".file_presigned_url",
        identity
    )
    mockery::stub(
        files_download,
        ".cellxgene_cache_get",
        function(x, y, progress) { names(x) <- y; x }
    )
    object <- files_download(files, dry.run = FALSE)

    expected <- with(files, paste0(.DATASETS, dataset_id, "/asset/", file_id))
    names(expected) <- with(
        files, paste0(dataset_id, ".", file_id, ".", filetype)
    )
    expect_identical(object, expected)
})
