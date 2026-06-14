# Retrieve updated cellxgene database metadata

Retrieve updated cellxgene database metadata

## Usage

``` r
db(overwrite = .db_online() && .db_first())
```

## Arguments

- overwrite:

  logical(1) indicating whether the database of collections should be
  updated from the internet (the default, when internet is available
  and, in an interactive session, the user requests the update), or read
  from disk (assuming previous successful access to the internet).
  `overwrite = FALSE` might be useful for reproducibility, testing, or
  when working in an environment with restricted internet access.

## Value

`db()` returns an object of class 'cellxgene_db', summarizing available
collections, datasets, and files.

## Details

The database is retrieved from the cellxgene data portal web site.
'collections' metadata are retrieved on each call; metadata on each
collection is cached locally for re-use.

## Examples

``` r
db()
#> Collections ■■                                 3% | ETA: 34s
#> Collections ■■                                 4% | ETA: 32s
#> Collections ■■■■■                             14% | ETA: 26s
#> Collections ■■■■■■■■■                         25% | ETA: 22s
#> Collections ■■■■■■■■■■■                       33% | ETA: 21s
#> Collections ■■■■■■■■■■■■■■                    44% | ETA: 18s
#> Collections ■■■■■■■■■■■■■■■■                  51% | ETA: 16s
#> Collections ■■■■■■■■■■■■■■■■■■■               61% | ETA: 12s
#> Collections ■■■■■■■■■■■■■■■■■■■■■■            71% | ETA:  9s
#> Collections ■■■■■■■■■■■■■■■■■■■■■■■■■■        82% | ETA:  6s
#> Collections ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     92% | ETA:  2s
#> Collections ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> cellxgene_db
#> number of collections(): 380
#> number of datasets(): 2127
#> number of files(): 2167
```
