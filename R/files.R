#' @rdname query
#'
#' @examples
#' files(db) |>
#'     dplyr::glimpse()
#'
#' @export
files <-
    function(cellxgene_db = db())
{
    .keys_query(cellxgene_db, "[].datasets[].dataset_assets[]", "files") |>
        relocate(file_id = "id")
}

## url <- "https://api.cellxgene.cziscience.com/dp/v1/datasets/86b37b3c-1e5e-46a9-aecc-2d95b6a38d4b/asset/e43c9f97-9d75-4a67-b62d-0170a597f914"

.file_download <-
    function(dataset_id, file_id, file_type, base_url, dry.run)
{
    ## construct url
    url <- paste0(base_url, dataset_id, "/asset/", file_id)

    ## sign
    response <- httr::POST(url)
    stop_for_status(response)
    result <- content(response, as="text", encoding = "UTF-8")


    ## download
    url <- jmespath(result, "presigned_url")
    file_name <- paste0(file_id, ".", file_type)
    if (dry.run) {
        message(
            "'files_download(dry.run = TRUE)'\n",
            "  file_id: ", file_id, "\n",
            "  file_name: ", file_name, "\n"
        )
        return(file_name)
    }
    .cellxgene_cache_get(url, file_name, progress = TRUE)
}

#' @rdname query
#'
#' @description `files_download()` retrieves one or more cellxgene
#'     files to a cache on the local system.
#'
#' @param dry.run logical(1) indicating whether the (often large)
#'     file(s) in `tbl` should be downloaded to a local cache. Files
#'     are not downloaded when `dry.run = TRUE` (default).
#'
#' @return `files_download()` returns a character() vector of paths to
#'     the local files.
#'
#' @examples
#' \dontrun{
#' files(db) |>
#'     dplyr::slice(1) |>
#'     files_download(dry.run = FALSE)
#' }
#'
#' @export
files_download <-
    function(tbl, dry.run = TRUE)
{
    stopifnot(
        all(c("dataset_id", "file_id", "filetype") %in% colnames(tbl)),
        .is_scalar_logical(dry.run)
    )

    result <- Map(
        .file_download,
        pull(tbl, "dataset_id"), pull(tbl, "file_id"), pull(tbl, "filetype"),
        MoreArgs = list(base_url = .DATASETS, dry.run = dry.run)
    )

    result
}
