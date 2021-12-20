#' @importFrom dplyr bind_rows mutate arrange desc
.db <-
    function()
{
    response <- .cellxgene_GET(.COLLECTIONS)
    content <- content(response)

    bind_rows(unname(content))
}

.db_detail <-
    function(id, as)
{
    uri <- paste0(.COLLECTIONS, id)
    path <- .cellxgene_cache_get(uri)
    readLines(path)
}

#' @importFrom parallel mclapply
#' @rdname db
#' @title Retrieve updated cellxgene database metadata
#'
#' @details The database is retrieved from the cellxgene data portal
#'     web site. 'collections' metadata are retrieved on each call;
#'     metadata on each collection is cached locally for re-use.
#'
#' @examples
#' db()
#'
#' @export
db <-
    function()
{
    db <- .db()
    details <- mclapply(db$id, .db_detail)
    details <- sprintf("[%s]", paste(details, collapse=","))
    class(details) <- c("cellxgene_db", class(details))

    details
}

#' @importFrom utils head
#'
#' @export
print.cellxgene_db <-
    function(x, ...)
{
    cat(
        head(class(x), 1L), "\n",
        "number of collections(): ", jmespath(x, "length([])"), "\n",
        "number of datasets(): ", jmespath(x, "length([].datasets[])"), "\n",
        "number of files(): ",
        jmespath(x, "length([].datasets[].dataset_assets[])"), "\n",
        sep = ""
    )
}
