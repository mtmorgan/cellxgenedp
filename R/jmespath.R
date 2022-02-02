#' @useDynLib cellxgenedp, .registration = TRUE
NULL

#' @rdname jmespath
#' @md
#'
#' @title Use JMESpath to query JSON files
#'
#' @description
#'
#'     `jmespath_version()` reports the version of the C++ jsoncons
#'     library in use.
#'
#'     `jmespath()` executes a query against a json string using the
#'     'jmespath' specification.
#'
#' @param data character(1) JSON string.
#'
#' @param path character(1) JMESpath query string.
#'
#' @details `jmespath()` is implemented in the jsoncons C++ library.
#'
#' @return
#'
#'     `jmespath_version()` returns a character(1) major.minor.patch
#'     version string describing the version of the jsoncons library
#'     on which jmespath is implemented.
#'
#'     `jmespath()` returns a character(1) json string representing
#'     the result of the query.
#'
#' @seealso https://danielaparker.github.io/jsoncons/
#'
#' @examples
#' jmespath_version()
#'
#' @export
jmespath_version <- function() {
    version <- cpp_version()
    package_version(version)
}

#' @rdname jmespath
#'
#' @examples
#' json <- '{
#'     "locations": [
#'         {"name": "Seattle", "state": "WA"},
#'         {"name": "New York", "state": "NY"},
#'         {"name": "Bellevue", "state": "WA"},
#'         {"name": "Olympia", "state": "WA"}
#'     ]
#' }'
#'
#' jmespath(json, "locations[?state == 'WA'].name | sort(@)") |>
#'     cat("\n")
#'
#' @export
jmespath <-
    function(data, path)
{
    stopifnot(
        .is_scalar_character(data),
        .is_scalar_character(path)
    )
    cpp_jmespath(data, path)
}
