#' @importFrom dplyr relocate
#' @rdname query
#'
#' @examples
#' datasets(db) |>
#'     dplyr::glimpse()
#'
#' @export
datasets <-
    function(cellxgene_db = db())
{
    collection_ids <- .jmes_to_r(cellxgene_db, "[].collection_id")
    datasets_per_collection <- .jmes_to_r(cellxgene_db, "[].length(datasets)")
    datasets <- .keys_query(cellxgene_db, "[].datasets[]", "datasets")
    datasets |>
        bind_cols(
            collection_id = rep(collection_ids, datasets_per_collection)
        ) |>
        relocate(
            "dataset_id", "dataset_version_id", "collection_id",
            everything()
        )
}

#' @importFrom utils browseURL
#' @importFrom dplyr distinct pull
#' @rdname query
#'
#' @param tbl a `tibble()` typically derived from `datasets(db)` or
#'     `files(db)` and containing columns `dataset_id` (for
#'     `datasets_visualize()`), or columns `dataset_id`, `file_id`,
#'     and `filetype` (for `files_download()`).
#'
#' @examples
#' \donttest{
#' if (interactive()) {
#'     ## visualize the first dataset
#'     datasets(db) |>
#'         dplyr::slice(1) |>
#'         datasets_visualize()
#' }
#' }
#' @export
datasets_visualize <-
    function(tbl)
{
    stopifnot(
        "dataset_id" %in% names(tbl)
    )

    dataset_ids <-
        tbl |>
        select(dataset_id) |>
        distinct() |>
        pull("dataset_id")
    if (length(dataset_ids) > 5L)
        stop("'visualize()' only allows up to 5 datasets per call")

    for (dataset_id in dataset_ids) {
        url <- paste0(.CELLXGENE_EXPLORER, dataset_id, ".cxg/")
        browseURL(url)
    }
}
