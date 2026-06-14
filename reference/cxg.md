# Shiny application for discovering, viewing, and downloading cellxgene data

Shiny application for discovering, viewing, and downloading cellxgene
data

## Usage

``` r
cxg(as = c("tibble", "sce"))
```

## Arguments

- as:

  character(1) Return value when quiting the shiny application.
  `"tibble"` returns a tibble describing selected datasets (including
  the location on disk of the downloaded file). `"sce"` returns a list
  of dataset files imported to R as SingleCellExperiment objects.

## Value

`cxg()` returns either a tibble describing datasets selected in the
shiny application, or a list of datasets imported into R as
SingleCellExperiment objects.

## Examples

``` r
# \donttest{
if (interactive())
    cxg()
# }
```
