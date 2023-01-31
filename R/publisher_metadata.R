authors <-
    function(cellxgene_db = db())
{
    has_publisher_metadata <-
        cellxgene_db |>
        .jmes_to_r("[*].contains(keys(@), 'publisher_metadata')")

    author_length <-
        .jmes_to_r(cellxgene_db, "[*].publisher_metadata[].length(authors)")
    author_path <- "[*].publisher_metadata[].authors[]"
    author <-
        .jmes_to_r(cellxgene_db, author_path) |>
        bind_rows() |>
        as_tibble()

    has_publisher_metadata <- .jmes_to_r(
        cellxgene_db, "[*].contains(keys(@), 'publisher_metadata')"
    )
    collection_id <- .jmes_to_r(cellxgene_db, "[*].id")
    collection_id <- rep(collection_id[has_publisher_metadata], author_length)
    bind_cols(
        tibble(collection_id = collection_id),
        author
    ) |> dplyr::rename(consortium = name)
}

publisher_metadata <-
    function(cellxgene_db = db())
{
    has_publisher_metadata <-
        cellxgene_db |>
        .jmes_to_r("[*].contains(keys(@), 'publisher_metadata')")

    keys <- c(
        "is_preprint", "journal",
        paste("published", c("at", "year", "month", "day"), sep = "_")
    )
    publisher_metadata_path <- paste0(
        "[*].publisher_metadata.{",
        paste(keys, keys, sep = ": ", collapse = ", "),
        "}"
    )

    publisher_metadata <-
        .jmes_to_r(cellxgene_db, publisher_metadata_path) |>
        bind_rows() |>
        as_tibble() |>
        mutate(published_at = as.Date(as.POSIXct(published_at)))

    collection_id <- .jmes_to_r(cellxgene_db, "[*].id")
    publisher_metadata <- bind_cols(
        tibble(collection_id = collection_id[has_publisher_metadata]),
        publisher_metadata
    )

    doi <-
        links() |>
        filter(link_type == "DOI") |>
        select(collection_id, doi = link_url)

    left_join(publisher_metadata, doi, by = "collection_id")
}
