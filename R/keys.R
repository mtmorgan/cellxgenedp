.KEYS_BLOCKLIST <- c("datasets", "assets")

.keys <-
    function(db, query_base, keys, path)
{
    query <- paste0(query_base, ".keys(@)")
    key_names <-
        .jmes_to_r(db, query) |>
        unlist() |>
        sort() |>
        setdiff(.KEYS_BLOCKLIST)
    key_paths <- paste0(query_base, ".", key_names)
    names(key_paths) <- key_names
    key_paths
}

#' @importFrom dplyr select across ends_with last_col everything
keys <-
    function(cellxgene_db = db())
{
    queries <- c(
        collections = "[]",
        datasets = "[].datasets[]",
        files = "[].datasets[].assets[]"
    )
    lapply(queries, .keys, db = cellxgene_db)
}

.keys_query <-
    function(db, prefix, key)
{
    stopifnot(
        inherits(db, "cellxgene_db"),
        .is_scalar_character(prefix),
        .is_scalar_character(key)
    )
    keys <- names(keys(db)[[key]])

    ## query -- prefix.{...} ensures all rows have all keys
    query <- paste0(
        prefix, ".{",
        paste0(keys, ":", keys, collapse = ","),
        "}"
    )
    lol <- .jmes_to_r(db, query, simplifyVector = FALSE)

    ## list-of-rows to list-of-columns
    keys <- names(lol[[1]])
    names(keys) <- keys
    lol <- lapply(keys, \(x) lapply(lol, `[[`, x))
    tbl <- do.call(tibble, lol)

    ## list(NULL) -> NA
    tbl[] <- lapply(tbl, \(x) {
        idx <- lengths(x) == 0L
        x[idx] <- NA
        x
    })

    ## unbox list columns where all entries are length 1
    idx <- vapply(tbl, \(x) all(lengths(x) == 1L), logical(1))
    idx[names(idx) %in% FACETS] <- FALSE # don't unbox facets
    tbl[idx] <- lapply(tbl[idx], unlist)

    ## timestamps to Date
    tbl <-
        tbl |>
        mutate(across(ends_with("_at"), .timestamp_to_date))

    ## format
    result <-
        tbl |>
        relocate(ends_with("_id"), everything()) |>
        relocate(ends_with("_at"), .after = last_col())

    ## class
    subclass <- paste0("cellxgene_keys_", key)
    class(result) <- c(subclass, "cellxgene_keys", class(result))

    result
}
