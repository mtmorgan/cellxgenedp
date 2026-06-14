# Facets available for querying cellxgene data

`FACETS` is a character vector of common fields used to subset cellxgene
data.

`facets()` is used to query the cellxgene database for current values of
one or all facets.

`facets_filter()` provides a convenient way to filter facets based on
label or ontology term.

## Usage

``` r
FACETS

facets(cellxgene_db = db(), facets = FACETS)

facets_filter(facet, key = c("label", "ontology_term_id"), value, exact = TRUE)
```

## Format

`FACETS` is an object of class `character` of length 8.

## Arguments

- cellxgene_db:

  an (optional) cellxgene_db object, as returned by
  [`db()`](https://mtmorgan.github.io/cellxgenedp/reference/db.md).

- facets:

  a character() vector corersponding to one of the facets in `FACETS`.

- facet:

  the column containing faceted information, e.g., `sex` in
  `datasets(db)`.

- key:

  character(1) identifying whether `value` is a `label` or
  `ontology_term_id`.

- value:

  character() value of the label or ontology term to filter on. The
  value may be a vector with `length(value) > 0` for exact matchs
  (`exact = TRUE`, default), or a `character(1)` regular expression.

- exact:

  logical(1) whether values match exactly (default, `TRUE`) or as a
  regular expression (`FALSE`).

## Value

`facets()` returns a tibble with columns `facet`, `label`,
`ontology_term_id`, and `n`, the number of times the facet label is used
in the database.

`facets_filter()` returns a logical vector with length equal to the
length (number of rows) of `facet`, with `TRUE` indicating that the
`value` of `key` is present in the dataset.

## Examples

``` r
f <- facets()

## levels of each facet
f |>
    dplyr::count(facet)
#> # A tibble: 8 × 2
#>   facet                       n
#>   <chr>                   <int>
#> 1 assay                      50
#> 2 cell_type                1122
#> 3 development_stage         292
#> 4 disease                   311
#> 5 organism                    9
#> 6 self_reported_ethnicity    44
#> 7 sex                         4
#> 8 tissue                    707

## same as facets(, facets = "organism")
f |>
    dplyr::filter(facet == "organism")
#> # A tibble: 9 × 4
#>   facet    label                 ontology_term_id     n
#>   <chr>    <chr>                 <chr>            <int>
#> 1 organism Homo sapiens          NCBITaxon:9606    1598
#> 2 organism Mus musculus          NCBITaxon:10090    421
#> 3 organism Danio rerio           NCBITaxon:7955      32
#> 4 organism Callithrix jacchus    NCBITaxon:9483      27
#> 5 organism Microcebus murinus    NCBITaxon:30608     27
#> 6 organism Macaca mulatta        NCBITaxon:9544      19
#> 7 organism Pan troglodytes       NCBITaxon:9598       1
#> 8 organism Sus scrofa            NCBITaxon:9823       1
#> 9 organism Sus scrofa domesticus NCBITaxon:9825       1

db <- db()
ds <- datasets(db)

## datasets with African American females
ds |>
    dplyr::filter(
        facets_filter(self_reported_ethnicity, "label", "African American"),
        facets_filter(sex, "label", "female")
    )
#> # A tibble: 198 × 36
#>    dataset_id   dataset_version_id collection_id donor_id assay  batch_condition
#>    <chr>        <chr>              <chr>         <list>   <list> <list>         
#>  1 d68a8b48-ab… 83bbeaaf-f5e0-42a… 3a5dbf8a-9b3… <chr>    <list> <lgl [1]>      
#>  2 0b4a15a7-4e… dad69d7e-fb52-46c… a98b828a-622… <chr>    <list> <lgl [1]>      
#>  3 fe2eecbc-97… 183c4a39-3a63-4d9… 7c4552fd-8a6… <chr>    <list> <chr [1]>      
#>  4 82346769-87… 9a6c52d0-4d3f-48c… 7c4552fd-8a6… <chr>    <list> <chr [1]>      
#>  5 38491c97-ce… 7778e9dd-6c23-4f0… 7c4552fd-8a6… <chr>    <list> <chr [1]>      
#>  6 15e0ec3e-a0… eb7f7869-eb13-4b2… 7c4552fd-8a6… <chr>    <list> <chr [1]>      
#>  7 0a2d7e87-c3… f298459d-ac2a-405… 7c4552fd-8a6… <chr>    <list> <chr [1]>      
#>  8 9813a1d4-d1… 9b87c411-2e17-4de… b953c942-f5d… <chr>    <list> <lgl [1]>      
#>  9 85c60876-7f… 5015051f-abc4-403… b953c942-f5d… <chr>    <list> <lgl [1]>      
#> 10 e47c65a8-7d… e9041e47-b470-4c4… 4195ab4c-20b… <chr>    <list> <lgl [1]>      
#> # ℹ 188 more rows
#> # ℹ 30 more variables: cell_count <int>, cell_type <list>, citation <chr>,
#> #   default_embedding <chr>, development_stage <list>, disease <list>,
#> #   embeddings <list>, explorer_url <chr>, feature_biotype <list>,
#> #   feature_count <int>, feature_reference <list>,
#> #   genetic_perturbation_strategy <lgl>, is_pre_analysis <lgl>,
#> #   is_primary_data <list>, mean_genes_per_cell <dbl>, organism <list>, …

## datasets with non-European, known ethnicity
facets(db, "self_reported_ethnicity")
#> # A tibble: 44 × 4
#>    facet                   label                          ontology_term_id     n
#>    <chr>                   <chr>                          <chr>            <int>
#>  1 self_reported_ethnicity unknown                        unknown           1437
#>  2 self_reported_ethnicity na                             na                 534
#>  3 self_reported_ethnicity Asian                          HANCESTRO:0847     296
#>  4 self_reported_ethnicity African American               HANCESTRO:0568     209
#>  5 self_reported_ethnicity European American              HANCESTRO:0590     182
#>  6 self_reported_ethnicity Hispanic or Latin              HANCESTRO:0612     177
#>  7 self_reported_ethnicity British                        HANCESTRO:0462      63
#>  8 self_reported_ethnicity Hispanic or Latin || Native A… HANCESTRO:0612 …    50
#>  9 self_reported_ethnicity South Asian                    HANCESTRO:0848      39
#> 10 self_reported_ethnicity Middle Eastern                 HANCESTRO:0852      29
#> # ℹ 34 more rows
ds |>
    dplyr::filter(
        !facets_filter(
            self_reported_ethnicity, "label", c("European", "na", "unknown")
        )
    )
#> # A tibble: 156 × 36
#>    dataset_id   dataset_version_id collection_id donor_id assay  batch_condition
#>    <chr>        <chr>              <chr>         <list>   <list> <list>         
#>  1 ed419b4e-db… c8da6eeb-84d7-437… af893e86-8e9… <chr>    <list> <lgl [1]>      
#>  2 aad97cb5-f3… 9db639c3-5c9c-4b8… af893e86-8e9… <chr>    <list> <lgl [1]>      
#>  3 8f10185b-e0… 45e411d4-c103-4c2… af893e86-8e9… <chr>    <list> <lgl [1]>      
#>  4 359f7af4-87… e3c7aa91-5edd-416… af893e86-8e9… <chr>    <list> <lgl [1]>      
#>  5 11ef37ee-21… 5903aa1b-c323-4ae… af893e86-8e9… <chr>    <list> <lgl [1]>      
#>  6 0129dbd9-a7… 7f2413c4-38c2-455… af893e86-8e9… <chr>    <list> <lgl [1]>      
#>  7 00e5dedd-b9… 3d0dcefd-cdf2-4b1… af893e86-8e9… <chr>    <list> <lgl [1]>      
#>  8 d68a8b48-ab… 83bbeaaf-f5e0-42a… 3a5dbf8a-9b3… <chr>    <list> <lgl [1]>      
#>  9 92594117-6e… a1e971da-5c35-46f… ad10cef8-9c6… <chr>    <list> <lgl [1]>      
#> 10 ca140407-ef… 2ab4df39-876d-4fd… 0540ee09-5b4… <chr>    <list> <lgl [1]>      
#> # ℹ 146 more rows
#> # ℹ 30 more variables: cell_count <int>, cell_type <list>, citation <chr>,
#> #   default_embedding <chr>, development_stage <list>, disease <list>,
#> #   embeddings <list>, explorer_url <chr>, feature_biotype <list>,
#> #   feature_count <int>, feature_reference <list>,
#> #   genetic_perturbation_strategy <lgl>, is_pre_analysis <lgl>,
#> #   is_primary_data <list>, mean_genes_per_cell <dbl>, organism <list>, …
```
