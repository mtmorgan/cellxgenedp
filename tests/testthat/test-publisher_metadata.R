test_that("links() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    links <- links()
    expect_true(nrow(links) >= 549L)

    link_types <- c(
        "OTHER", "RAW_DATA", "DOI", "PROTOCOL", "DATA_SOURCE",
        "LAB_WEBSITE"
    )
    expect_true(all(link_types %in% unique(pull(links, "link_type"))))

    ## used in vignette
    doi_of_interest <- "https://doi.org/10.1016/j.xcrm.2021.100219"
    rows_of_interest <-
        links |>
        filter(link_type == "DOI" & link_url == doi_of_interest) |>
        nrow()
    expect_identical(rows_of_interest, 1L)
})

test_that("authors() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    authors <- authors()
    expect_true(nrow(authors) >= 3571L)

    ## used in vignette
    collection_id_of_interest <- "c9706a92-0e5f-46c1-96d8-20e42467f287"
    rows_of_interest <-
        authors |>
        filter(collection_id == collection_id_of_interest) |>
        nrow()
    expect_identical(rows_of_interest, 12L)
})

test_that("publisher_metadata() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    publisher_metadata <- publisher_metadata()
    expect_true(nrow(publisher_metadata) >= 113L)

    ## used in vignette
    collection_id_of_interest <- "c9706a92-0e5f-46c1-96d8-20e42467f287"
    rows_of_interest <-
        publisher_metadata |>
        filter(collection_id == collection_id_of_interest)
    expect_identical(nrow(rows_of_interest), 1L)
})
