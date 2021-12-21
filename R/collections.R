#' @rdname query
#' @title Query cellxgene collections, datasets, and files
#'
#' @param cellxgene_db an optional 'cellxgene_db' object, as returned
#'     by `db()`.
#'
#' @return Each function returns a tibble describing the corresponding
#'     component of the database.
#'
#' @examples
#' db <- db()
#'
#' collections(db)
#'
#' collections(db) |>
#'     dplyr::glimpse()
#'
#' @export
collections <-
    function(cellxgene_db = db())
{
    .keys_query(cellxgene_db, "[]", "collections") |>
        relocate(collection_id = "id")
}

#' @rdname view
#' @title Simplified views of cellxgene collections, datasets, and files
#'
#' @param cellxgene_db an optional 'cellxgene_db' object, as returned
#'     by `db()`.
#'
#' @return Each function returns a tibble with a simplified
#'     description of the corresponding component of the database.
#' @examples
#'
#' db <- db()
#'
#' collections_view(db)
#'
#' datasets_view(db)
#'
#' files_view(db)
#'
#' @export
collections_view <-
    function(cellxgene_db = db())
{
    stopifnot(
        inherits(cellxgene_db, "cellxgene_db")
    )

    df <-
        cellxgene_db |>
        jmespath(
            "[].{
                collection: name,
                tissue: datasets[].tissue[].label,
                assay: datasets[].assay[].label,
                disease: datasets[].disease[].label,
                organism: datasets[].organism[].label,
                cell_count: datasets[].cell_count,
                collection_id: id
            }"
        ) |>
        fromJSON()

    result <-
        tibble(df) |>
        mutate(
            cell_count = vapply(.data$cell_count, sum, integer(1))
        ) |>
        select(
            "collection", "cell_count", "assay", "tissue", "disease",
            "organism", everything()
        )

    class(result) <- c(
        "cellxgene_view_collections", "cellxgene_view", class(result)
    )
    result
}
