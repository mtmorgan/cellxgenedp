#' @importFrom dplyr relocate
#' @rdname query
#'
#' @examples
#' datasets(db) |>
#'     dplyr::glimpse()
#'
#' @export
datasets <-
    function(cellxgene_db = db)
{
    .keys_query(cellxgene_db, "[].datasets[]", "datasets") |>
        relocate(dataset_id = "id")
}

#' @importFrom dplyr as_tibble select everything
#' @importFrom tidyr unnest
#' @rdname view
#'
#' @export
datasets_view <-
    function(cellxgene_db = db())
{
    stopifnot(
        inherits(cellxgene_db, "cellxgene_db")
    )
    lol <-
        cellxgene_db |>
        jmespath(
            "[].{
                collection: name,
                dataset: datasets[].name,
                tissue: datasets[].tissue[].label,
                assay: datasets[].assay[].label,
                disease: datasets[].disease[].label,
                organism: datasets[].organism[].label,
                cell_count: datasets[].cell_count,
                collection_id: id,
                dataset_id: datasets[].id
            }"
        ) |>
        fromJSON()

    if (is.null(names(lol))) {
        result <- lol |>
            bind_rows() |>
            unnest("dataset")
    } else {
        result <- as_tibble(lol)
    }

    result <-
        result |>
        unnest(cols = c("dataset", "dataset_id", "cell_count")) |>
        select(
            "collection", "dataset", "cell_count", "assay", "tissue",
            "disease", "organism", everything()
        )

    class(result) <- c(
        "cellxgene_view_dataset", "cellxgene_view", class(result)
    )
    result
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
#' \dontrun{
#' ## visualize the first dataset
#' datasets(db) |>
#'     slice(1) |>
#'     datasets_visualize()
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
