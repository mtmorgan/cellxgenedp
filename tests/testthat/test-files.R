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
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    files <- files() |> head(2)
    object <- with_mock(
        .file_presigned_url = identity,
        .cellxgene_cache_get = \(x, y, progress) { names(x) <- y; x },
        files_download(files, dry.run = FALSE)
    )

    expected <- with(files, paste0(.DATASETS, dataset_id, "/asset/", file_id))
    names(expected) <- with(
        files, paste0(dataset_id, ".", file_id, ".", filetype)
    )
    expect_identical(object, expected)
})
