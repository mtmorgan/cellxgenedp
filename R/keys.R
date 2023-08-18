.KEYS_BLOCKLIST <- c("datasets", "assets")

.keys <-
    function(db, query_base, keys, path)
{
    query <- paste0(query_base, ".keys(@)")
    key_names <-
        .jmes_to_r(db, query) |>
        setdiff(.KEYS_BLOCKLIST)
    path_base <- gsub("[0]", "[]", query_base, fixed = TRUE)
    key_paths <- paste0(path_base, ".", key_names)
    names(key_paths) <- key_names
    key_paths
}

#' @importFrom dplyr select across ends_with last_col everything
keys <-
    function(cellxgene_db = db())
{
    queries <- c(
        collections = "[0]",
        datasets = "[0].datasets[0]",
        files = "[0].datasets[0].assets[0]"
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

    ## unbox
    idx <- vapply(tbl, \(x) all(lengths(x) == 1L), logical(1))
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
