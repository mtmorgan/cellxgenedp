#' @rdname facets
#' @title Facets available for querying cellxgene data
#'
#' @description `FACETS` is a character vector of common fields used
#'     to subset cellxgene data.
#'
#' @format `FACETS` is an object of class `character` of length 8.
#'
#' @export
FACETS <- c(
    "assay", "cell_type", "development_stage", "disease",
    "ethnicity", "organism", "processing_status", "sex", "tissue"
)

.facet <-
    function(cellxgene_db, facet)
{

    query <- sprintf(
        "[].datasets[].%s[*].{
             label: label, ontology_term_id: ontology_term_id
         }[]",
        facet
    )
    projection <-
        cellxgene_db |>
        jmespath(query) |>
        fromJSON(simplifyVector = FALSE)

    projection |>
        bind_rows() |>
        group_by(.data$label, .data$ontology_term_id) |>
        count(sort = TRUE) |>
        ungroup() |>
        bind_cols(tibble(facet))
}

#' @importFrom dplyr group_by ungroup count bind_cols tibble .data
#' @importFrom jsonlite fromJSON
#' @rdname facets
#'
#' @description `facets()` is used to query the cellxgene database for
#'     current values of one or all facets.
#'
#' @param cellxgene_db an (optional) cellxgene_db object, as returned
#'     by `db()`.
#'
#' @param facets a character() vector corersponding to one of the
#'     facets in `FACETS`.
#'
#' @return `facets()` returns a tibble with columns `facet`, `label`,
#'     `ontology_term_id`, and `n`, the number of times the facet
#'     label is used in the database.
#'
#' @examples
#' f <- facets()
#'
#' ## levels of each facet
#' f |>
#'     dplyr::count(facet)
#'
#' ## same as facets(, facets = "organism")
#' f |>
#'     dplyr::filter(facet == "organism")
#'
#' @export
facets <-
    function(cellxgene_db = db(), facets = FACETS)
{
    stopifnot(
        inherits(cellxgene_db, "cellxgene_db"),
        all(facets %in% FACETS)
    )

    terms <- lapply(facets, .facet, cellxgene_db = cellxgene_db)

    terms |>
        bind_rows() |>
        select("facet", "label", "ontology_term_id", "n")
}
