#' @rdname query
#'
#' @export
files <-
    function(cellxgene_db = db())
{
    .keys_query(cellxgene_db, "[].datasets[].dataset_assets[]", "files") |>
        relocate(file_id = "id")
}

#' @rdname view
#'
#' @export
files_view <-
    function(cellxgene_db = db())
{
    df <-
        cellxgene_db |>
        jmespath(
            "[].{
            collection: name,
            dataset: datasets[].name,
            filetype: datasets[].dataset_assets[*].filetype,
            type: datasets[].dataset_assets[*].type,
            collection_id: id,
            dataset_id: datasets[].id,
            file_id: datasets[].dataset_assets[*].id
            }"
        ) |>
        fromJSON(simplifyVector = FALSE)
    result <-
        df |>
        bind_rows() |>
        as_tibble() |>
        unnest(c(
            "dataset", "dataset_id",
            "filetype", "type", "file_id"
        )) |>
        unnest(c(
            "filetype", "type", "file_id"
        )) |>
        select(
            "collection", "dataset", "filetype", "type", everything()
        )

    class(result) <- c("cellxgene_view_file", "cellxgene_view", class(result))
    result
}
