#' @rdname query
#'
#' @description `links()`, `authors()` and `publisher_metadata()` are
#'     helper functions to extract 'nested' information from
#'     collections.
#'
#' @return `links()` returns a tibble of external links associated
#'     with each collection. Common links includ DOI, raw data / data
#'     sources, and lab websites.
#'
#' @examples
#' ## common links to external data
#' links(db) |>
#'     dplyr::count(link_type)
#'
#' @export
links <-
    function(cellxgene_db = db())
{
    link_lengths <-
        .jmes_to_r(cellxgene_db, "[*].length(links)[]")
    collection_ids <- .jmes_to_r(cellxgene_db, "[*].id")
    collection_id <- tibble(collection_id = rep(collection_ids, link_lengths))
    links <-
        cellxgene_db |>
        .jmes_to_r("[*].links[*]") |>
        ## create a single tibble
        bind_rows() |>
        as_tibble() |>
        ## clean up unnamed links from '""' to NA
        mutate(
            link_name = ifelse(
                nzchar(.data$link_name), .data$link_name, NA_character_
            )
        )

    bind_cols(collection_id, links)
}

#' @rdname query
#'
#' @return `authors()` returns a tibble of authors associated with
#'     each collection.
#'
#' @examples
#' ## authors per collection
#' authors() |>
#'     dplyr::count(collection_id, sort = TRUE)
#'
#' @importFrom dplyr rename
#'
#' @export
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
        as_tibble() |>
        rename(consortium = "name")

    has_publisher_metadata <- .jmes_to_r(
        cellxgene_db, "[*].contains(keys(@), 'publisher_metadata')"
    )
    collection_id <- .jmes_to_r(cellxgene_db, "[*].id")
    collection_id <- rep(collection_id[has_publisher_metadata], author_length)
    bind_cols(
        tibble(collection_id = collection_id),
        author
    )
}

#' @rdname query
#'
#' @return `publisher_metadata()` returns a tibble of publisher
#'     metadata (journal, publicate date, doi) associated with each
#'     collection.
#'
#' @examples
#' publisher_metadata() |>
#'     dplyr::glimpse()
#'
#' @export
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
        mutate(
            published_at = as.Date(as.POSIXct(
                .data$published_at, origin = "1970-01-01 00:00.00 UTC"
            ))
        )

    collection_id <- .jmes_to_r(cellxgene_db, "[*].id")
    name <- .jmes_to_r(cellxgene_db, "[*].name")
    publisher_metadata <- bind_cols(
        tibble(
            collection_id = collection_id[has_publisher_metadata],
            name = name[has_publisher_metadata],
        ),
        publisher_metadata
    )

    doi <-
        links() |>
        filter(.data$link_type == "DOI") |>
        select(collection_id, doi = "link_url")

    left_join(publisher_metadata, doi, by = "collection_id")
}
