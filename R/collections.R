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
