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
    "ethnicity", "organism", "sex", "tissue"
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
        parse_json()

    projection |>
        bind_rows() |>
        group_by(.data$label, .data$ontology_term_id) |>
        count(sort = TRUE) |>
        ungroup() |>
        bind_cols(tibble(facet))
}

#' @importFrom dplyr group_by ungroup count bind_cols tibble .data
#' @importFrom jsonlite parse_json
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

#' @rdname facets
#'
#' @description `facets_filter()` provides a convenient way to filter
#'     facets based on label or ontology term.
#'
#' @param facet the column containing faceted information, e.g., `sex`
#'     in `datasets(db)`.
#'
#' @param key character(1) identifying whether `value` is a `label` or
#'     `ontology_term_id`.
#'
#' @param value character() value of the label or ontology term to
#'     filter on. The value may be a vector with `length(value) > 0`
#'     for exact matchs (`exact = TRUE`, default), or a `character(1)`
#'     regular expression.
#'
#' @param exact logical(1) whether values match exactly (default,
#'     `TRUE`) or as a regular expression (`FALSE`).
#'
#' @return `facets_filter()` returns a logical vector with length
#'     equal to the length (number of rows) of `facet`, with `TRUE`
#'     indicating that the `value` of `key` is present in the dataset.
#'
#' @examples
#' db <- db()
#' ds <- datasets(db)
#'
#' ## datasets with African American females
#' ds |>
#'     dplyr::filter(
#'         facets_filter(ethnicity, "label", "African American"),
#'         facets_filter(sex, "label", "female")
#'     )
#'
#' ## datasets with non-European, known ethnicity
#' facets(db, "ethnicity")
#' ds |>
#'     dplyr::filter(
#'         !facets_filter(ethnicity, "label", c("European", "na", "unknown"))
#'     )
#'
#' @export
facets_filter <-
    function(facet, key = c("label", "ontology_term_id"), value, exact = TRUE)
{
    key <- match.arg(key)
    stopifnot(
        (exact && is.character(value)) ||
            (!exact && .is_scalar_character(value)),
        .is_scalar_logical(exact)
    )

    row_index <- rep(seq_along(facet), lengths(facet))
    facet_kv <- unlist(facet, recursive = FALSE, use.names = FALSE)
    values <- vapply(facet_kv, `[[`, character(1), key)
    if (exact) {
        found_index <- row_index[values %in% value]
    } else {
        found_index <- row_index[grepl(value, values)]
    }
    seq_along(facet) %in% found_index
}
