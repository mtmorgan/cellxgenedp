#' @importFrom dplyr relocate
#' @rdname query
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
