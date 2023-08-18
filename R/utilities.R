.timestamp_to_date <-
    function(x)
{
    as.Date(as.POSIXct(x, origin = "1970-01-01"))
}

.is_scalar <-
    function(x)
{
    length(x) == 1L && !is.na(x)
}

.is_scalar_character <-
    function(x)
{
    .is_scalar(x) && is.character(x) && nzchar(x)
}

.is_scalar_logical <-
    function(x)
{
    .is_scalar(x) && is.logical(x)
}

#' @importFrom rjsoncons jmespath
.jmes_to_r <-
    function(db, path, ..., simplifyVector = TRUE)
{
    jmespath(db, path) |>
        parse_json(..., simplifyVector = simplifyVector)
}

.onLoad <-
    function(libname, pkgname)
{
    ## reset the cache once a week on the builders
    if (identical(Sys.getenv("IS_BIOC_BUILD_MACHINE"), "true")) {
        cache_path <- .cellxgene_cache_path()
        if (dir.exists(cache_path)) {
            creation_time <-  file.info(cache_path, extra_cols = FALSE)$ctime
            age <- difftime(Sys.Date(), creation_time, units = "days")
            if (age > 7) {
                unlink(cache_path, recursive = TRUE, force =  TRUE)
            }
        }
    }
}
