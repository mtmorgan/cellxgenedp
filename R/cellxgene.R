## package-global variables

.CELLXGENE_PRODUCTION_ENDPOINT <- 'https://api.cellxgene.cziscience.com'

.DATASETS <- paste0(.CELLXGENE_PRODUCTION_ENDPOINT, "/dp/v1/datasets/")

.COLLECTIONS <- paste0(.CELLXGENE_PRODUCTION_ENDPOINT, "/dp/v1/collections/")

.CELLXGENE_EXPLORER <- "https://cellxgene.cziscience.com/e/"

#' @importFrom httr GET write_disk progress status_code
#'     stop_for_status content headers
.cellxgene_GET <-
    function(uri)
{
    response <- GET(uri)
    stop_for_status(response)
    response
}

#' @importFrom tools R_user_dir
.cellxgene_cache_path <-
    function()
{
    path <- R_user_dir("cellxgenedp", "cache")
    if (!dir.exists(path))
        dir.create(path, recursive = TRUE)
    path
}

.cellxgene_cache_get <-
    function(uri, file = basename(uri), progress = FALSE, overwrite = FALSE)
{
    path <- file.path(.cellxgene_cache_path(), file)
    if (overwrite || !file.exists(path)) {
        response <- GET(
            uri,
            if (progress) progress(),
            write_disk(path, overwrite = overwrite)
        )
        if (status_code(response) >= 400L) {
            unlink(path)
            stop_for_status(response)
        }
    }
    path
}

#' @importFrom dplyr select ends_with
#' @rdname view
#'
#' @param x an object created by `collections_view()`,
#'     `datasets_view()`, or `files_view()`.
#'
#' @param ... additional arguments required by `print()`, but ignored.
#'
#' @param with_ids logical(1) indicating whether collection, dataset,
#'     and file ids should be displayed.
#'
#' @export
print.cellxgene_view <-
    function(x, ..., with_ids = FALSE)
{
    stopifnot(
        .is_scalar_logical(with_ids)
    )
    if (!with_ids)
        x <- dplyr::select(x, -ends_with("_id"))
    NextMethod(x, ...)
}
