test_that("facets() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    facets <- facets()
    expect_true(nrow(facets) >= 743L)
    FACETS_COLUMNS <- c(
        facet="character", label="character", ontology_term_id="character",
        n="integer"
    )
    columns <- vapply(facets, class, character(1))
    expect_identical(columns, FACETS_COLUMNS)
    expect_identical(dim(count(facets, facet)), c(8L, 2L))
})

test_that("facets_filter() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    dataset <- structure(
        list(
            id = 1:2,
            sex=list(
                list(
                    list(label = "female", ontology_term_id = "PATO:0000383"), 
                    list(label = "male", ontology_term_id = "PATO:0000384")
                ), 
                list(
                    list(label = "female", ontology_term_id = "PATO:0000383"), 
                    list(label = "male", ontology_term_id = "PATO:0000384"), 
                    list(label = "unknown", ontology_term_id = "unknown")
                )
            )
        ),
        row.names = c(NA, -2L),
        class = c(
            "cellxgene_keys_datasets", "cellxgene_keys", "tbl_df", "tbl",
            "data.frame"
        )
    )

    object <- dplyr::filter(dataset, facets_filter(sex, "label", "unknown"))
    expect_identical(object$id, 2L)

    object <- dplyr::filter(dataset, !facets_filter(sex, "label", "unknown"))
    expect_identical(object$id, 1L)

    object <- dplyr::filter(
        dataset,
        facets_filter(sex, "ontology_term_id", "PATO:0000384")
    )
    expect_identical(object$id, 1:2)

    object <- dplyr::filter(
        dataset,
        !facets_filter(sex, "ontology_term_id", "PATO:0000384")
    )
    expect_identical(object$id, integer())
})
