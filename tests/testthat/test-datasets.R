test_that("datasets() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    datasets <- datasets()
    expect_true(nrow(datasets) >= 223L)
    DATASETS_COLUMNS <- c(
        dataset_id="character", collection_id="character",
        assay="list", cell_count="integer", cell_type="list",
        dataset_deployments="character",
        development_stage="list", disease="list", ethnicity="list",
        is_primary_data="character", is_valid="logical",
        linked_genesets="logical", mean_genes_per_cell="numeric",
        name="character", organism="list", processing_status="list",
        published="logical", revision="integer", schema_version="character",
        sex="list", tissue="list", tombstone="logical",
        x_normalization="character", created_at="Date", published_at="Date",
        revised_at="Date", updated_at="Date"
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
