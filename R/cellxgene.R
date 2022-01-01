## package-global variables

.CELLXGENE_PRODUCTION_HOST <- "api.cellxgene.cziscience.com"

.CELLXGENE_PRODUCTION_ENDPOINT <- paste0("https://", .CELLXGENE_PRODUCTION_HOST)

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
    function(path = R_user_dir("cellxgenedp", "cache"))
{
    if (!dir.exists(path))
        dir.create(path, recursive = TRUE)
    path
}

.cellxgene_cache_get <-
    function(uri, file = basename(uri), progress = FALSE, overwrite = FALSE,
             cache_path = .cellxgene_cache_path())
{
    path <- file.path(cache_path, file)
    if (overwrite || !file.exists(path)) {
        ## download to path0 and then copy / unlink to path to avoid
        ## overwriting file with failed attempt. Don't use
        ## file.rename() since this will fail when tempfile() and
        ## cache are on separate file systems.
        path0 <- tempfile()
        response <- GET(
            uri,
            if (progress) progress(),
            write_disk(path0, overwrite = overwrite)
        )
        if (status_code(response) >= 400L) {
            unlink(path0)
            stop_for_status(response)
        }
        file.copy(path0, path, overwrite = TRUE)
        unlink(path0)
    }
    path
}
