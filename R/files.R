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
    dataset_ids <- .jmes_to_r(cellxgene_db, "[].datasets[].dataset_id")
    files_per_dataset <- .jmes_to_r(
        cellxgene_db, "[].datasets[].length(assets)"
    )
    files <- .keys_query(cellxgene_db, "[].datasets[].assets[]", "files")
    bind_cols(
        dataset_id = rep(dataset_ids, files_per_dataset),
        files
    )
}

.file_download <-
    function(dataset_id, file_type, url, dry.run, cache.path)
{
    file_name <- basename(url)
    if (dry.run) {
        message(
            "'files_download(dry.run = TRUE)'\n",
            "  file_name: ", file_name, "\n"
        )
        return(file_name)
    }

    ## download
    .cellxgene_cache_get(
        url, file_name, progress = interactive(), cache_path = cache.path
    )
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
#' @param cache.path character(1) directory in which to cache
#'     downloaded files. The directory must already exist. The default
#'     is `tools::R_user_dir("cellxgenedp", "cache")`, a
#'     package-specific path in the user home directory.
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
    function(tbl, dry.run = TRUE, cache.path = .cellxgene_cache_path())
{
    stopifnot(
        all(c("dataset_id", "filetype", "url") %in% colnames(tbl)),
        .is_scalar_logical(dry.run),
        .is_scalar_character(cache.path), dir.exists(cache.path)
    )

    result <- Map(
        .file_download,
        pull(tbl, "dataset_id"), pull(tbl, "filetype"), pull(tbl, "url"),
        MoreArgs = list(dry.run = dry.run, cache.path = cache.path)
    )

    if (identical(length(result), 0L)) {
        result <- character()
        names(result) <- character()
    } else {
        result <- unlist(result)
    }
    result
}
