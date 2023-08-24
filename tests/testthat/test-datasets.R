test_that("datasets() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    datasets <- datasets()
    expect_true(nrow(datasets) >= 223L)
    DATASETS_COLUMNS <- c(
        dataset_id = "character",
        dataset_version_id = "character",
        collection_id = "character",
        donor_id = "list",
        assay = "list",
        batch_condition = "list",
        cell_count = "integer",
        cell_type = "list",
        development_stage = "list",
        disease = "list",
        explorer_url = "character",
        is_primary_data = "list",
        mean_genes_per_cell = "numeric",
        organism = "list",
        schema_version = "character",
        self_reported_ethnicity = "list",
        sex = "list",
        suspension_type = "list",
        tissue = "list", title = "character",
        tombstone = "logical",
        x_approximate_distribution = "character",
        published_at = "Date",
        revised_at = "Date"
    )
    column_names <- names(DATASETS_COLUMNS)
    expect_true(all(column_names %in% names(datasets)))
    columns <- vapply(datasets[column_names], class, character(1))
    expect_identical(columns, DATASETS_COLUMNS)
})

test_that("datasets_visualize() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    datasets <-
        datasets() |>
        head(2)

    object <- NULL
    mockery::stub(datasets_visualize, "browseURL", \(x) object <<- c(object, x))
    datasets_visualize(datasets)

    expected <- paste0(.CELLXGENE_EXPLORER, datasets$dataset_id, ".cxg/")
    expect_identical(object, expected)
})
