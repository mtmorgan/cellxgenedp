
# Installation and use

This package is available in *Bioconductor* version 3.15 and later. The
following code installs
[cellxgenedp](https://bioconductor.org/packages/cellxgenedp) as well as
other packages required for this vignette.

``` r
pkgs <- c("cellxgenedp", "zellkonverter", "SingleCellExperiment", "HDF5Array")
required_pkgs <- pkgs[!pkgs %in% rownames(installed.packages())]
BiocManager::install(required_pkgs)
```

Use the following `pkgs` vector to install from GitHub (latest,
unchecked, development version) instead

``` r
pkgs <- c(
    "mtmorgan/cellxgenedp", "zellkonverter", "SingleCellExperiment", "HDF5Array"
)
```

Load the package into your current *R* session. We make extensive use of
the dplyr packages, and at the end of the vignette use
SingleCellExperiment and zellkonverter, so load those as well.

``` r
suppressPackageStartupMessages({
    library(zellkonverter)
    library(SingleCellExperiment) # load early to avoid masking dplyr::count()
    library(dplyr)
    library(cellxgenedp)
})
```

# `cxg()` Provides a ‘shiny’ interface

The following sections outline how to use the
[cellxgenedp](https://bioconductor.org/packages/cellxgenedp) package in
an *R* script; most functionality is also available in the `cxg()` shiny
application, providing an easy way to identify, download, and visualize
one or several datasets. Start the app

``` r
cxg()
```

choose a project on the first tab, and a dataset for visualization, or
one or more datasets for download!

# Collections, datasets and files

Retrieve metadata about resources available at the cellxgene data portal
using `db()`:

``` r
db <- db()
```

Printing the `db` object provides a brief overview of the available
data, as well as hints, in the form of functions like `collections()`,
for further exploration.

``` r
db
#> cellxgene_db
#> number of collections(): 119
#> number of datasets(): 706
#> number of files(): 2813
```

The portal organizes data hierarchically, with ‘collections’ (research
studies, approximately), ‘datasets’, and ‘files’. Discover data using
the corresponding functions.

``` r
collections(db)
#> # A tibble: 119 × 15
#>    collec…¹ acces…² conso…³ conta…⁴ conta…⁵ curat…⁶ data_…⁷ descr…⁸ links  name 
#>    <chr>    <chr>   <lgl>   <chr>   <chr>   <chr>   <chr>   <chr>   <list> <chr>
#>  1 43d4bb3… READ    NA      raymon… Raymon… Batuha… 1.0     Pertur… <list> Tran…
#>  2 0434a9d… READ    NA      avilla… Alexan… Batuha… 1.0     The va… <list> Acut…
#>  3 03cdc7f… READ    NA      tien.p… Tien P… Jason … 1.0     scRNA-… <lgl>  Emph…
#>  4 2902f08… READ    NA      lopes@… S. M. … Wei Kh… 1.0     The ov… <list> Sing…
#>  5 83ed3be… READ    NA      tom.ta… Tom Ta… Jennif… 1.0     During… <list> Inte…
#>  6 eb735cc… READ    NA      rv4@sa… Roser … Batuha… 1.0     Human … <list> Samp…
#>  7 44531dd… READ    NA      tallul… Tallul… Jennif… 1.0     The cr… <list> Sing…
#>  8 e75342a… READ    NA      nhuebn… Norber… Jennif… 1.0     Pathog… <list> Path…
#>  9 64b24fd… READ    NA      magnes… Scott … Rachel… 1.0     Single… <list> A pr…
#> 10 125eef5… READ    NA      my4@sa… Matthe… Jason … 1.0     Unders… <list> Sing…
#> # … with 109 more rows, 5 more variables: publisher_metadata <list>,
#> #   visibility <chr>, created_at <date>, published_at <date>,
#> #   updated_at <date>, and abbreviated variable names ¹​collection_id,
#> #   ²​access_type, ³​consortia, ⁴​contact_email, ⁵​contact_name, ⁶​curator_name,
#> #   ⁷​data_submission_policy_version, ⁸​description

datasets(db)
#> # A tibble: 706 × 26
#>    dataset_id     colle…¹ donor…² assay  cell_…³ cell_…⁴ datas…⁵ devel…⁶ disease
#>    <chr>          <chr>   <list>  <list>   <int> <list>  <chr>   <list>  <list> 
#>  1 d62144d1-6e98… 43d4bb… <list>  <list>   68036 <list>  https:… <list>  <list> 
#>  2 07f8f239-2136… 0434a9… <list>  <list>   59506 <list>  https:… <list>  <list> 
#>  3 9aca7e29-d19c… 03cdc7… <list>  <list>   35699 <list>  https:… <list>  <list> 
#>  4 731aeab6-e1d6… 03cdc7… <list>  <list>    3662 <list>  https:… <list>  <list> 
#>  5 bfdafcbc-d785… 03cdc7… <list>  <list>   18386 <list>  https:… <list>  <list> 
#>  6 218af677-b80b… 2902f0… <list>  <list>   20676 <list>  https:… <list>  <list> 
#>  7 9e11bf54-0ea6… 83ed3b… <list>  <list>   71732 <list>  https:… <list>  <list> 
#>  8 a0b9d32b-4085… eb735c… <list>  <list>   97499 <list>  https:… <list>  <list> 
#>  9 5daeaafe-c79e… 44531d… <list>  <list>     146 <list>  https:… <list>  <list> 
#> 10 cc607851-8820… 44531d… <list>  <list>    2346 <list>  https:… <list>  <list> 
#> # … with 696 more rows, 17 more variables: is_primary_data <chr>,
#> #   is_valid <lgl>, mean_genes_per_cell <dbl>, name <chr>, organism <list>,
#> #   processing_status <list>, published <lgl>, revision <int>,
#> #   schema_version <chr>, self_reported_ethnicity <list>, sex <list>,
#> #   suspension_type <list>, tissue <list>, tombstone <lgl>, created_at <date>,
#> #   published_at <date>, updated_at <date>, and abbreviated variable names
#> #   ¹​collection_id, ²​donor_id, ³​cell_count, ⁴​cell_type, ⁵​dataset_deployments, …

files(db)
#> # A tibble: 2,813 × 8
#>    file_id          datas…¹ filen…² filet…³ s3_uri user_…⁴ created_at updated_at
#>    <chr>            <chr>   <chr>   <chr>   <chr>  <lgl>   <date>     <date>    
#>  1 87ce2086-f2eb-4… d62144… "raw.h… RAW_H5… s3://… TRUE    1970-01-01 1970-01-01
#>  2 8eabe485-be71-4… d62144… "local… H5AD    s3://… TRUE    1970-01-01 1970-01-01
#>  3 33dfa406-132a-4… d62144… "local… RDS     s3://… TRUE    1970-01-01 1970-01-01
#>  4 454e0b3c-e207-4… d62144… ""      CXG     s3://… TRUE    1970-01-01 1970-01-01
#>  5 62deea2a-d722-4… 07f8f2… "raw.h… RAW_H5… s3://… TRUE    1970-01-01 1970-01-01
#>  6 b50c48f1-ef5e-4… 07f8f2… "local… H5AD    s3://… TRUE    1970-01-01 1970-01-01
#>  7 59309f21-0db8-4… 07f8f2… "local… RDS     s3://… TRUE    1970-01-01 1970-01-01
#>  8 399c2655-f56a-4… 07f8f2… ""      CXG     s3://… TRUE    1970-01-01 1970-01-01
#>  9 1ca25a06-7251-4… 9aca7e… "raw.h… RAW_H5… s3://… TRUE    1970-01-01 1970-01-01
#> 10 a2dd5b48-98df-4… 9aca7e… "local… H5AD    s3://… TRUE    1970-01-01 1970-01-01
#> # … with 2,803 more rows, and abbreviated variable names ¹​dataset_id,
#> #   ²​filename, ³​filetype, ⁴​user_submitted
```

Each of these resources has a unique primary identifier (e.g.,
`file_id`) as well as an identifier describing the relationship of the
resource to other components of the database (e.g., `dataset_id`). These
identifiers can be used to ‘join’ information across tables.

## Using `dplyr` to navigate data

A collection may have several datasets, and datasets may have several
files. For instance, here is the collection with the most datasets

``` r
collection_with_most_datasets <-
    datasets(db) |>
    count(collection_id, sort = TRUE) |>
    slice(1)
```

We can find out about this collection by joining with the
`collections()` table.

``` r
left_join(
    collection_with_most_datasets |> select(collection_id),
    collections(db),
    by = "collection_id"
) |> glimpse()
#> Rows: 1
#> Columns: 15
#> $ collection_id                  <chr> "283d65eb-dd53-496d-adb7-7570c7caa443"
#> $ access_type                    <chr> "READ"
#> $ consortia                      <lgl> NA
#> $ contact_email                  <chr> "kimberly.siletti@ki.se"
#> $ contact_name                   <chr> "Kimberly Siletti"
#> $ curator_name                   <chr> "James Chaffer"
#> $ data_submission_policy_version <chr> "1.0"
#> $ description                    <chr> "The human brain directs a wide range o…
#> $ links                          <list> [["", "RAW_DATA", "http://data.nemoarch…
#> $ name                           <chr> "Transcriptomic diversity of cell types…
#> $ publisher_metadata             <list> [[["Siletti", "Kimberly"], ["Hodge", "R…
#> $ visibility                     <chr> "PUBLIC"
#> $ created_at                     <date> 2022-11-09
#> $ published_at                   <date> 2022-12-09
#> $ updated_at                     <date> 2022-12-09
```

We can take a similar strategy to identify all datasets belonging to
this collection

``` r
left_join(
    collection_with_most_datasets |> select(collection_id),
    datasets(db),
    by = "collection_id"
)
#> Warning in left_join(select(collection_with_most_datasets, collection_id), : Each row in `x` is expected to match at most 1 row in `y`.
#> ℹ Row 1 of `x` matches multiple rows.
#> ℹ If multiple matches are expected, set `multiple = "all"` to silence this
#>   warning.
#> # A tibble: 138 × 26
#>    collection_id  datas…¹ donor…² assay  cell_…³ cell_…⁴ datas…⁵ devel…⁶ disease
#>    <chr>          <chr>   <list>  <list>   <int> <list>  <chr>   <list>  <list> 
#>  1 283d65eb-dd53… 4fb0cd… <list>  <list>   25071 <list>  https:… <list>  <list> 
#>  2 283d65eb-dd53… d15266… <list>  <list>   35290 <list>  https:… <list>  <list> 
#>  3 283d65eb-dd53… f4c89e… <list>  <list>   38331 <list>  https:… <list>  <list> 
#>  4 283d65eb-dd53… fb3dee… <list>  <list>   21534 <list>  https:… <list>  <list> 
#>  5 283d65eb-dd53… 7e0f26… <list>  <list>    9932 <list>  https:… <list>  <list> 
#>  6 283d65eb-dd53… 0834c8… <list>  <list>   28724 <list>  https:… <list>  <list> 
#>  7 283d65eb-dd53… 4cce2e… <list>  <list>   35359 <list>  https:… <list>  <list> 
#>  8 283d65eb-dd53… 05dd9b… <list>  <list>   27210 <list>  https:… <list>  <list> 
#>  9 283d65eb-dd53… 5b994d… <list>  <list>   26172 <list>  https:… <list>  <list> 
#> 10 283d65eb-dd53… dab53e… <list>  <list>   34933 <list>  https:… <list>  <list> 
#> # … with 128 more rows, 17 more variables: is_primary_data <chr>,
#> #   is_valid <lgl>, mean_genes_per_cell <dbl>, name <chr>, organism <list>,
#> #   processing_status <list>, published <lgl>, revision <int>,
#> #   schema_version <chr>, self_reported_ethnicity <list>, sex <list>,
#> #   suspension_type <list>, tissue <list>, tombstone <lgl>, created_at <date>,
#> #   published_at <date>, updated_at <date>, and abbreviated variable names
#> #   ¹​dataset_id, ²​donor_id, ³​cell_count, ⁴​cell_type, ⁵​dataset_deployments, …
```

## `facets()` provides information on ‘levels’ present in specific columns

Notice that some columns are ‘lists’ rather than atomic vectors like
‘character’ or ‘integer’.

``` r
datasets(db) |>
    select(where(is.list))
#> # A tibble: 706 × 11
#>    donor_id   assay  cell_…¹ devel…² disease organ…³ processing…⁴ self_…⁵ sex   
#>    <list>     <list> <list>  <list>  <list>  <list>  <list>       <list>  <list>
#>  1 <list [9]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  2 <list>     <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  3 <list [6]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  4 <list [6]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  5 <list [6]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  6 <list [5]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  7 <list [5]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  8 <list>     <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  9 <list [4]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#> 10 <list [4]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#> # … with 696 more rows, 2 more variables: suspension_type <list>,
#> #   tissue <list>, and abbreviated variable names ¹​cell_type,
#> #   ²​development_stage, ³​organism, ⁴​processing_status, ⁵​self_reported_ethnicity
```

This indicates that at least some of the datasets had more than one type
of `assay`, `cell_type`, etc. The `facets()` function provides a
convenient way of discovering possible levels of each column, e.g.,
`assay`, `organism`, `self_reported_ethnicity`, or `sex`, and the number
of datasets with each label.

``` r
facets(db, "assay")
#> # A tibble: 32 × 4
#>    facet label                          ontology_term_id     n
#>    <chr> <chr>                          <chr>            <int>
#>  1 assay 10x 3' v3                      EFO:0009922        346
#>  2 assay 10x 3' v2                      EFO:0009899        170
#>  3 assay Slide-seqV2                    EFO:0030062        129
#>  4 assay 10x 5' v1                      EFO:0011025         48
#>  5 assay Smart-seq2                     EFO:0008931         38
#>  6 assay Visium Spatial Gene Expression EFO:0010961         35
#>  7 assay 10x multiome                   EFO:0030059         24
#>  8 assay Drop-seq                       EFO:0008722         12
#>  9 assay 10x 3' transcription profiling EFO:0030003          9
#> 10 assay 10x 5' v2                      EFO:0009900          9
#> # … with 22 more rows
facets(db, "self_reported_ethnicity")
#> # A tibble: 18 × 4
#>    facet                   label                                   ontol…¹     n
#>    <chr>                   <chr>                                   <chr>   <int>
#>  1 self_reported_ethnicity unknown                                 unknown   358
#>  2 self_reported_ethnicity European                                HANCES…   200
#>  3 self_reported_ethnicity na                                      na        184
#>  4 self_reported_ethnicity Asian                                   HANCES…    81
#>  5 self_reported_ethnicity African American                        HANCES…    39
#>  6 self_reported_ethnicity multiethnic                             multie…    25
#>  7 self_reported_ethnicity Greater Middle Eastern  (Middle Easter… HANCES…    21
#>  8 self_reported_ethnicity Hispanic or Latin American              HANCES…    16
#>  9 self_reported_ethnicity African American or Afro-Caribbean      HANCES…    10
#> 10 self_reported_ethnicity East Asian                              HANCES…     4
#> 11 self_reported_ethnicity African                                 HANCES…     3
#> 12 self_reported_ethnicity South Asian                             HANCES…     2
#> 13 self_reported_ethnicity Chinese                                 HANCES…     1
#> 14 self_reported_ethnicity Eskimo                                  HANCES…     1
#> 15 self_reported_ethnicity Finnish                                 HANCES…     1
#> 16 self_reported_ethnicity Han Chinese                             HANCES…     1
#> 17 self_reported_ethnicity Oceanian                                HANCES…     1
#> 18 self_reported_ethnicity Pacific Islander                        HANCES…     1
#> # … with abbreviated variable name ¹​ontology_term_id
facets(db, "sex")
#> # A tibble: 3 × 4
#>   facet label   ontology_term_id     n
#>   <chr> <chr>   <chr>            <int>
#> 1 sex   male    PATO:0000384       614
#> 2 sex   female  PATO:0000383       371
#> 3 sex   unknown unknown             54
```

## Filtering faceted columns

Suppose we were interested in finding datasets from the 10x 3’ v3 assay
(`ontology_term_id` of `EFO:0009922`) containing individuals of African
American ethnicity, and female sex. Use the `facets_filter()` utility
function to filter data sets as needed

``` r
african_american_female <-
    datasets(db) |>
    filter(
        facets_filter(assay, "ontology_term_id", "EFO:0009922"),
        facets_filter(self_reported_ethnicity, "label", "African American"),
        facets_filter(sex, "label", "female")
    )
```

Use `nrow(african_american_female)` to find the number of datasets
satisfying our criteria. It looks like there are up to

``` r
african_american_female |>
    summarise(total_cell_count = sum(cell_count))
#> # A tibble: 1 × 1
#>   total_cell_count
#>              <int>
#> 1          2657433
```

cells sequenced (each dataset may contain cells from several
ethnicities, as well as males or individuals of unknown gender, so we do
not know the actual number of cells available without downloading
files). Use `left_join` to identify the corresponding collections:

``` r
## collections
left_join(
    african_american_female |> select(collection_id) |> distinct(),
    collections(db),
    by = "collection_id"
)
#> # A tibble: 8 × 15
#>   collect…¹ acces…² conso…³ conta…⁴ conta…⁵ curat…⁶ data_…⁷ descr…⁸ links  name 
#>   <chr>     <chr>   <lgl>   <chr>   <chr>   <chr>   <chr>   <chr>   <list> <chr>
#> 1 c9706a92… READ    NA      hnaksh… Harikr… Jennif… 1.0     "Singl… <list> A si…
#> 2 2f75d249… READ    NA      rsatij… Rahul … Jennif… 1.0     "This … <list> Azim…
#> 3 62e8f058… READ    NA      chanj3… Joseph… Jennif… 1.0     "155,0… <list> HTAN…
#> 4 625f6bf4… READ    NA      a5wang… Allen … Jennif… 1.0     "Large… <list> Lung…
#> 5 b953c942… READ    NA      icobos… Inma C… Jennif… 1.0     "Tau a… <list> Sing…
#> 6 bcb61471… READ    NA      info@k… KPMP    Jennif… 1.0     "Under… <list> An a…
#> 7 b9fc3d70… READ    NA      bruce.… Bruce … Jennif… 1.0     "Numer… <list> A We…
#> 8 a98b828a… READ    NA      markus… Markus… Jennif… 1.0     "Tumor… <list> HCA …
#> # … with 5 more variables: publisher_metadata <list>, visibility <chr>,
#> #   created_at <date>, published_at <date>, updated_at <date>, and abbreviated
#> #   variable names ¹​collection_id, ²​access_type, ³​consortia, ⁴​contact_email,
#> #   ⁵​contact_name, ⁶​curator_name, ⁷​data_submission_policy_version, ⁸​description
```

## Publication and other external data

Many collections include publication information and other external
data. This information is available in the return value of
`collections()`, but the helper function `publisher_metadata()`,
`authors()`, and `links()` may facilite access.

Suppose one is interested in the publication “A single-cell atlas of the
healthy breast tissues reveals clinically relevant clusters of breast
epithelial cells”. Discover it in the collections

``` r
title_of_interest <- paste(
    "A single-cell atlas of the healthy breast tissues reveals clinically",
    "relevant clusters of breast epithelial cells"
)
collection_of_interest <-
    collections(db) |>
    dplyr::filter(startsWith(name, title_of_interest))
collection_of_interest |>
    glimpse()
#> Rows: 1
#> Columns: 15
#> $ collection_id                  <chr> "c9706a92-0e5f-46c1-96d8-20e42467f287"
#> $ access_type                    <chr> "READ"
#> $ consortia                      <lgl> NA
#> $ contact_email                  <chr> "hnakshat@iupui.edu"
#> $ contact_name                   <chr> "Harikrishna Nakshatri"
#> $ curator_name                   <chr> "Jennifer Yu-Sheng Chien"
#> $ data_submission_policy_version <chr> "1.0"
#> $ description                    <chr> "Single-cell RNA sequencing (scRNA-seq)…
#> $ links                          <list> [["", "RAW_DATA", "https://data.humance…
#> $ name                           <chr> "A single-cell atlas of the healthy bre…
#> $ publisher_metadata             <list> [[["Bhat-Nakshatri", "Poornima"], ["Gao…
#> $ visibility                     <chr> "PUBLIC"
#> $ created_at                     <date> 2021-03-25
#> $ published_at                   <date> 2021-03-25
#> $ updated_at                     <date> 2021-03-25
```

Use the `collection_id` to extract publisher metadata (including a DOI
if available) and author information

``` r
collection_id_of_interest <- pull(collection_of_interest, "collection_id")
publisher_metadata(db) |>
    filter(collection_id == collection_id_of_interest) |>
    glimpse()
#> Rows: 1
#> Columns: 9
#> $ collection_id   <chr> "c9706a92-0e5f-46c1-96d8-20e42467f287"
#> $ name            <chr> "A single-cell atlas of the healthy breast tissues rev…
#> $ is_preprint     <lgl> FALSE
#> $ journal         <chr> "Cell Reports Medicine"
#> $ published_at    <date> 2021-03-01
#> $ published_year  <int> 2021
#> $ published_month <int> 3
#> $ published_day   <int> 1
#> $ doi             <chr> "https://doi.org/10.1016/j.xcrm.2021.100219"
authors(db) |>
    filter(collection_id == collection_id_of_interest)
#> # A tibble: 12 × 4
#>    collection_id                        family         given       consortium
#>    <chr>                                <chr>          <chr>       <chr>     
#>  1 c9706a92-0e5f-46c1-96d8-20e42467f287 Bhat-Nakshatri Poornima    <NA>      
#>  2 c9706a92-0e5f-46c1-96d8-20e42467f287 Gao            Hongyu      <NA>      
#>  3 c9706a92-0e5f-46c1-96d8-20e42467f287 Sheng          Liu         <NA>      
#>  4 c9706a92-0e5f-46c1-96d8-20e42467f287 McGuire        Patrick C.  <NA>      
#>  5 c9706a92-0e5f-46c1-96d8-20e42467f287 Xuei           Xiaoling    <NA>      
#>  6 c9706a92-0e5f-46c1-96d8-20e42467f287 Wan            Jun         <NA>      
#>  7 c9706a92-0e5f-46c1-96d8-20e42467f287 Liu            Yunlong     <NA>      
#>  8 c9706a92-0e5f-46c1-96d8-20e42467f287 Althouse       Sandra K.   <NA>      
#>  9 c9706a92-0e5f-46c1-96d8-20e42467f287 Colter         Austyn      <NA>      
#> 10 c9706a92-0e5f-46c1-96d8-20e42467f287 Sandusky       George      <NA>      
#> 11 c9706a92-0e5f-46c1-96d8-20e42467f287 Storniolo      Anna Maria  <NA>      
#> 12 c9706a92-0e5f-46c1-96d8-20e42467f287 Nakshatri      Harikrishna <NA>
```

Collections may have links to additional external data, in this case a
DOI and two links to `RAW_DATA`.

``` r
external_links <- links(db)
external_links
#> # A tibble: 586 × 4
#>    collection_id                        link_name                link_…¹ link_…²
#>    <chr>                                <chr>                    <chr>   <chr>  
#>  1 43d4bb39-21af-4d05-b973-4c1fed7b916c <NA>                     OTHER   http:/…
#>  2 43d4bb39-21af-4d05-b973-4c1fed7b916c <NA>                     DOI     https:…
#>  3 43d4bb39-21af-4d05-b973-4c1fed7b916c EGAS00001002927          DATA_S… https:…
#>  4 0434a9d4-85fd-4554-b8e3-cf6c582bb2fa Purification of PBMCs    PROTOC… https:…
#>  5 0434a9d4-85fd-4554-b8e3-cf6c582bb2fa <NA>                     DOI     https:…
#>  6 0434a9d4-85fd-4554-b8e3-cf6c582bb2fa MGH COVID-19 Effort Blo… PROTOC… http:/…
#>  7 0434a9d4-85fd-4554-b8e3-cf6c582bb2fa COVID Blood Processing … PROTOC… http:/…
#>  8 0434a9d4-85fd-4554-b8e3-cf6c582bb2fa CITE-seq for PBMCs       PROTOC… https:…
#>  9 0434a9d4-85fd-4554-b8e3-cf6c582bb2fa COVID Airway Processing… PROTOC… http:/…
#> 10 0434a9d4-85fd-4554-b8e3-cf6c582bb2fa <NA>                     OTHER   https:…
#> # … with 576 more rows, and abbreviated variable names ¹​link_type, ²​link_url
external_links |>
    count(link_type)
#> # A tibble: 6 × 2
#>   link_type       n
#>   <chr>       <int>
#> 1 DATA_SOURCE    37
#> 2 DOI           115
#> 3 LAB_WEBSITE    31
#> 4 OTHER         205
#> 5 PROTOCOL       36
#> 6 RAW_DATA      162
external_links |>
    filter(collection_id == collection_id_of_interest)
#> # A tibble: 3 × 4
#>   collection_id                        link_name link_type link_url             
#>   <chr>                                <chr>     <chr>     <chr>                
#> 1 c9706a92-0e5f-46c1-96d8-20e42467f287 <NA>      RAW_DATA  https://data.humance…
#> 2 c9706a92-0e5f-46c1-96d8-20e42467f287 <NA>      DOI       https://doi.org/10.1…
#> 3 c9706a92-0e5f-46c1-96d8-20e42467f287 <NA>      RAW_DATA  https://www.ncbi.nlm…
```

Conversely, knowledge of a DOI, etc., can be used to discover details of
the corresponding collection.

``` r
doi_of_interest <- "https://doi.org/10.1016/j.xcrm.2021.100219"
links(db) |>
    filter(link_type == "DOI" & link_url == doi_of_interest) |>
    left_join(collections(db)) |>
    glimpse()
#> Joining with `by = join_by(collection_id)`
#> Rows: 1
#> Columns: 18
#> $ collection_id                  <chr> "c9706a92-0e5f-46c1-96d8-20e42467f287"
#> $ link_name                      <chr> NA
#> $ link_type                      <chr> "DOI"
#> $ link_url                       <chr> "https://doi.org/10.1016/j.xcrm.2021.10…
#> $ access_type                    <chr> "READ"
#> $ consortia                      <lgl> NA
#> $ contact_email                  <chr> "hnakshat@iupui.edu"
#> $ contact_name                   <chr> "Harikrishna Nakshatri"
#> $ curator_name                   <chr> "Jennifer Yu-Sheng Chien"
#> $ data_submission_policy_version <chr> "1.0"
#> $ description                    <chr> "Single-cell RNA sequencing (scRNA-seq)…
#> $ links                          <list> [["", "RAW_DATA", "https://data.humance…
#> $ name                           <chr> "A single-cell atlas of the healthy bre…
#> $ publisher_metadata             <list> [[["Bhat-Nakshatri", "Poornima"], ["Gao…
#> $ visibility                     <chr> "PUBLIC"
#> $ created_at                     <date> 2021-03-25
#> $ published_at                   <date> 2021-03-25
#> $ updated_at                     <date> 2021-03-25
```

# Visualizing data in `cellxgene`

Discover files associated with our first selected dataset

``` r
selected_files <-
    left_join(
        african_american_female |> select(dataset_id),
        files(db),
        by = "dataset_id"
    )
#> Warning in left_join(select(african_american_female, dataset_id), files(db), : Each row in `x` is expected to match at most 1 row in `y`.
#> ℹ Row 1 of `x` matches multiple rows.
#> ℹ If multiple matches are expected, set `multiple = "all"` to silence this
#>   warning.
selected_files
#> # A tibble: 88 × 8
#>    dataset_id       file_id filen…¹ filet…² s3_uri user_…³ created_at updated_at
#>    <chr>            <chr>   <chr>   <chr>   <chr>  <lgl>   <date>     <date>    
#>  1 24205601-0780-4… e1c842… "raw.h… RAW_H5… s3://… TRUE    1970-01-01 1970-01-01
#>  2 24205601-0780-4… 15e9d9… "local… H5AD    s3://… TRUE    1970-01-01 1970-01-01
#>  3 24205601-0780-4… 0d3974… ""      CXG     s3://… TRUE    1970-01-01 1970-01-01
#>  4 24205601-0780-4… e254f9… "local… RDS     s3://… TRUE    1970-01-01 1970-01-01
#>  5 d084f1e1-42f1-4… 59bd46… "local… RDS     s3://… TRUE    1970-01-01 1970-01-01
#>  6 d084f1e1-42f1-4… 3a2467… ""      CXG     s3://… TRUE    1970-01-01 1970-01-01
#>  7 d084f1e1-42f1-4… d9f9d0… "local… H5AD    s3://… TRUE    1970-01-01 1970-01-01
#>  8 d084f1e1-42f1-4… bee803… "raw.h… RAW_H5… s3://… TRUE    1970-01-01 1970-01-01
#>  9 3f40e6b1-e280-4… e47e72… "raw.h… RAW_H5… s3://… TRUE    1970-01-01 1970-01-01
#> 10 3f40e6b1-e280-4… d72756… "local… H5AD    s3://… TRUE    1970-01-01 1970-01-01
#> # … with 78 more rows, and abbreviated variable names ¹​filename, ²​filetype,
#> #   ³​user_submitted
```

The `filetype` column lists the type of each file. The cellxgene service
can be used to visualize *datasets* that have `CXG` files.

``` r
selected_files |>
    filter(filetype == "CXG") |>
    slice(1) |> # visualize a single dataset
    datasets_visualize()
```

Visualization is an interactive process, so `datasets_visualize()` will
only open up to 5 browser tabs per call.

# File download and use

Datasets usually contain `CXG` (cellxgene visualization), `H5AD` (files
produced by the python AnnData module), and `Rds` (serialized files
produced by the *R* Seurat package). There are no public parsers for
`CXG`, and the `Rds` files may be unreadable if the version of Seurat
used to create the file is different from the version used to read the
file. We therefore focus on the `H5AD` files. For illustration, we
download one of our selected files.

``` r
local_file <-
    selected_files |>
    filter(
        dataset_id == "24205601-0780-4bf2-b1d9-0e3cacbc2cd6",
        filetype == "H5AD"
    ) |>
    files_download(dry.run = FALSE)
basename(local_file)
#> [1] "15e9d9af-60dc-4897-88e4-89842655d6b8.H5AD"
```

These are downloaded to a local cache (use the internal function
`cellxgenedp:::.cellxgenedb_cache_path()` for the location of the
cache), so the process is only time-consuming the first time.

`H5AD` files can be converted to *R* / *Bioconductor* objects using the
[zellkonverter](https://bioconductor.org/packages/zelkonverter) package.

``` r
h5ad <- readH5AD(local_file, use_hdf5 = TRUE)
#> + '/home/runner/.cache/R/basilisk/1.10.2/0/bin/conda' 'create' '--yes' '--prefix' '/home/runner/.cache/R/basilisk/1.10.2/zellkonverter/1.8.0/zellkonverterAnnDataEnv-0.8.0' 'python=3.8.13' '--quiet' '-c' 'conda-forge'
#> + '/home/runner/.cache/R/basilisk/1.10.2/0/bin/conda' 'install' '--yes' '--prefix' '/home/runner/.cache/R/basilisk/1.10.2/zellkonverter/1.8.0/zellkonverterAnnDataEnv-0.8.0' 'python=3.8.13'
#> + '/home/runner/.cache/R/basilisk/1.10.2/0/bin/conda' 'install' '--yes' '--prefix' '/home/runner/.cache/R/basilisk/1.10.2/zellkonverter/1.8.0/zellkonverterAnnDataEnv-0.8.0' '-c' 'conda-forge' 'python=3.8.13' 'anndata=0.8.0' 'h5py=3.6.0' 'hdf5=1.12.1' 'natsort=8.1.0' 'numpy=1.22.3' 'packaging=21.3' 'pandas=1.4.2' 'python=3.8.13' 'scipy=1.7.3' 'sqlite=3.38.2'
#> Warning: 'X' matrix does not support transposition and has been skipped
h5ad
#> class: SingleCellExperiment 
#> dim: 33234 31696 
#> metadata(3): default_embedding schema_version title
#> assays(1): X
#> rownames(33234): ENSG00000243485 ENSG00000237613 ... ENSG00000277475
#>   ENSG00000268674
#> rowData names(4): feature_is_filtered feature_name feature_reference
#>   feature_biotype
#> colnames(31696): CMGpool_AAACCCAAGGACAACC CMGpool_AAACCCACAATCTCTT ...
#>   K109064_TTTGTTGGTTGCATCA K109064_TTTGTTGGTTGGACCC
#> colData names(34): donor_id self_reported_ethnicity_ontology_term_id
#>   ... self_reported_ethnicity development_stage
#> reducedDimNames(3): X_pca X_tsne X_umap
#> mainExpName: NULL
#> altExpNames(0):
```

The `SingleCellExperiment` object is a matrix-like object with rows
corresponding to genes and columns to cells. Thus we can easily explore
the cells present in the data.

``` r
h5ad |>
    colData(h5ad) |>
    as_tibble() |>
    count(sex, donor_id)
#> # A tibble: 7 × 3
#>   sex    donor_id                     n
#>   <fct>  <fct>                    <int>
#> 1 female D1                        2303
#> 2 female D2                         864
#> 3 female D3                        2517
#> 4 female D4                        1771
#> 5 female D5                        2244
#> 6 female D11                       7454
#> 7 female pooled [D9,D7,D8,D10,D6] 14543
```

# Next steps

The [Orchestrating Single-Cell Analysis with
Bioconductor](https://bioconductor.org/books/OSCA) online resource
provides an excellent introduction to analysis and visualization of
single-cell data in *R* / *Bioconductor*. Extensive opportunities for
working with AnnData objects in *R* but using the native python
interface are briefly described in, e.g., `?AnnData2SCE` help page of
[zellkonverter](https://bioconductor.org/packages/zelkonverter).

The [hca](https://bioconductor.org/packages/hca) package provides
programmatic access to the Human Cell Atlas [data
portal](https://data.humancellatlas.org/explore), allowing retrieval of
primary as well as derived single-cell data files.

# Session info

    #> R version 4.2.2 (2022-10-31)
    #> Platform: x86_64-pc-linux-gnu (64-bit)
    #> Running under: Ubuntu 22.04.1 LTS
    #> 
    #> Matrix products: default
    #> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
    #> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.20.so
    #> 
    #> locale:
    #>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    #>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    #>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    #> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    #> 
    #> attached base packages:
    #> [1] stats4    stats     graphics  grDevices datasets  utils     methods  
    #> [8] base     
    #> 
    #> other attached packages:
    #>  [1] cellxgenedp_1.3.3           dplyr_1.1.0                
    #>  [3] SingleCellExperiment_1.20.0 SummarizedExperiment_1.28.0
    #>  [5] Biobase_2.58.0              GenomicRanges_1.50.2       
    #>  [7] GenomeInfoDb_1.34.9         IRanges_2.32.0             
    #>  [9] S4Vectors_0.36.1            BiocGenerics_0.44.0        
    #> [11] MatrixGenerics_1.10.0       matrixStats_0.63.0         
    #> [13] zellkonverter_1.8.0        
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] Rcpp_1.0.10            here_1.0.1             dir.expiry_1.6.0      
    #>  [4] lattice_0.20-45        png_0.1-8              rprojroot_2.0.3       
    #>  [7] digest_0.6.31          utf8_1.2.3             mime_0.12             
    #> [10] R6_2.5.1               evaluate_0.20          httr_1.4.4            
    #> [13] pillar_1.8.1           basilisk_1.10.2        zlibbioc_1.44.0       
    #> [16] rlang_1.0.6            curl_5.0.0             Matrix_1.5-1          
    #> [19] DT_0.27                reticulate_1.28        rmarkdown_2.20        
    #> [22] htmlwidgets_1.6.1      RCurl_1.98-1.10        shiny_1.7.4           
    #> [25] DelayedArray_0.24.0    compiler_4.2.2         httpuv_1.6.8          
    #> [28] xfun_0.37              pkgconfig_2.0.3        htmltools_0.5.4       
    #> [31] tidyselect_1.2.0       tibble_3.1.8           GenomeInfoDbData_1.2.9
    #> [34] codetools_0.2-18       fansi_1.0.4            withr_2.5.0           
    #> [37] later_1.3.0            bitops_1.0-7           rjsoncons_1.0.0       
    #> [40] basilisk.utils_1.10.0  grid_4.2.2             jsonlite_1.8.4        
    #> [43] xtable_1.8-4           lifecycle_1.0.3        magrittr_2.0.3        
    #> [46] cli_3.6.0              XVector_0.38.0         renv_0.16.0           
    #> [49] promises_1.2.0.1       ellipsis_0.3.2         filelock_1.0.2        
    #> [52] generics_0.1.3         vctrs_0.5.2            tools_4.2.2           
    #> [55] glue_1.6.2             parallel_4.2.2         fastmap_1.1.0         
    #> [58] yaml_2.3.7             knitr_1.42
