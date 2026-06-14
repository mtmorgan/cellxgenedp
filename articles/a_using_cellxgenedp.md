# Discovery and retrieval

Abstract

The CELLxGENE data portal (<https://cellxgene.cziscience.com/>) provides
a graphical user interface to collections of single-cell sequence data
processed in standard ways to ‘count matrix’ summaries. The cellxgenedp
package provides an alternative, R-based interface, allowing flexible
data discovery, viewing, and retrieval.

NOTE: The interface to CELLxGENE has changed; versions of
[cellxgenedp](https://mtmorgan.github.io/cellxgenedp) prior to 1.4.1 /
1.5.2 will cease to work when CELLxGENE removes the previous interface.
See the vignette section ‘API changes’ for additional details.

## Installation and use

This package is available in *Bioconductor* version 3.15 and later. The
following code installs
[cellxgenedp](https://bioconductor.org/packages/cellxgenedp) from
*Bioconductor*

``` r

if (!"BiocManager" %in% rownames(installed.packages()))
    install.packages("BiocManager", repos = "https://CRAN.R-project.org")
BiocManager::install("cellxgenedp")
```

Alternatively, install the ‘development’ version from GitHub (see
[GitHub.io](https://mtmorgan.github.io/cellxgenedp) for current
documentation)

``` r

if (!"remotes" %in% rownames(installed.packages()))
    install.packages("remotes", repos = "https://CRAN.R-project.org")
remotes::install_github("mtmorgan/cellxgenedp")
```

To also install additional packages required for this vignette, use

``` r

pkgs <- c("tidyr", "zellkonverter", "SingleCellExperiment", "HDF5Array")
required_pkgs <- pkgs[!pkgs %in% rownames(installed.packages())]
BiocManager::install(required_pkgs)
```

Load the package into your current *R* session. We make extensive use of
the dplyr packages, and at the end of the vignette use
SingleCellExperiment and zellkonverter, so load those as well.

``` r

library(zellkonverter)
library(SingleCellExperiment) # load early to avoid masking dplyr::count()
library(dplyr)
library(cellxgenedp)
```

## `cxg()` Provides a ‘shiny’ interface

The following sections outline how to use the
[cellxgenedp](https://mtmorgan.github.io/cellxgenedp) package in an *R*
script; most functionality is also available in the
[`cxg()`](https://mtmorgan.github.io/cellxgenedp/reference/cxg.md) shiny
application, providing an easy way to identify, download, and visualize
one or several datasets. Start the app

``` r

cxg()
```

choose a project on the first tab, and a dataset for visualization, or
one or more datasets for download!

## Collections, datasets and files

Retrieve metadata about resources available at the cellxgene data portal
using [`db()`](https://mtmorgan.github.io/cellxgenedp/reference/db.md):

``` r

db <- db()
```

Printing the `db` object provides a brief overview of the available
data, as well as hints, in the form of functions like
[`collections()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md),
for further exploration.

``` r

db
```

    ## cellxgene_db
    ## number of collections(): 380
    ## number of datasets(): 2127
    ## number of files(): 2167

The portal organizes data hierarchically, with ‘collections’ (research
studies, approximately), ‘datasets’, and ‘files’. Discover data using
the corresponding functions.

``` r

collections(db)
```

    ## # A tibble: 380 × 19
    ##    collection_id    collection_version_id collection_url consortia contact_email
    ##    <chr>            <chr>                 <chr>          <list>    <chr>        
    ##  1 af893e86-8e9f-4… c1b538fd-0f01-41c8-a… https://cellx… <chr [1]> ruichen@bcm.…
    ##  2 3a5dbf8a-9b3e-4… c656236c-fc37-4470-a… https://cellx… <chr [1]> xinsun@ucsd.…
    ##  3 16876983-d454-4… ea4e5a38-8adb-4ca3-9… https://cellx… <lgl [1]> ryan.corces@…
    ##  4 ad10cef8-9c6c-4… 6f05ce2a-2fca-424c-8… https://cellx… <lgl [1]> jiyeon.choi2…
    ##  5 7f7fdf50-aa0e-4… eed80e7c-54ff-40ae-a… https://cellx… <chr [1]> ca3@sanger.a…
    ##  6 35928d1c-36fc-4… bfa09492-85f4-473e-b… https://cellx… <chr [1]> jeremym@alle…
    ##  7 e02201d7-f49f-4… c8280cb1-208f-4eca-8… https://cellx… <chr [1]> richard.smit…
    ##  8 0540ee09-5b45-4… 27a2b3bf-c7f3-4138-9… https://cellx… <lgl [1]> ynose@gesurg…
    ##  9 9b02383a-9358-4… 0bb91d14-4427-4e5a-9… https://cellx… <chr [1]> parkerw@wust…
    ## 10 8a05eaf6-5680-4… 633a21eb-5a97-401d-9… https://cellx… <lgl [1]> EichholJ@msk…
    ## # ℹ 370 more rows
    ## # ℹ 14 more variables: contact_name <chr>, curator_name <chr>,
    ## #   description <chr>, doi <chr>, is_pre_analysis <lgl>, links <list>,
    ## #   name <chr>, publisher_metadata <list>, revising_in <lgl>,
    ## #   revision_of <lgl>, visibility <chr>, created_at <date>,
    ## #   published_at <date>, revised_at <date>

``` r

datasets(db)
```

    ## # A tibble: 2,127 × 36
    ##    dataset_id   dataset_version_id collection_id donor_id assay  batch_condition
    ##    <chr>        <chr>              <chr>         <list>   <list> <list>         
    ##  1 ed419b4e-db… c8da6eeb-84d7-437… af893e86-8e9… <chr>    <list> <lgl [1]>      
    ##  2 aad97cb5-f3… 9db639c3-5c9c-4b8… af893e86-8e9… <chr>    <list> <lgl [1]>      
    ##  3 8f10185b-e0… 45e411d4-c103-4c2… af893e86-8e9… <chr>    <list> <lgl [1]>      
    ##  4 359f7af4-87… e3c7aa91-5edd-416… af893e86-8e9… <chr>    <list> <lgl [1]>      
    ##  5 11ef37ee-21… 5903aa1b-c323-4ae… af893e86-8e9… <chr>    <list> <lgl [1]>      
    ##  6 0129dbd9-a7… 7f2413c4-38c2-455… af893e86-8e9… <chr>    <list> <lgl [1]>      
    ##  7 00e5dedd-b9… 3d0dcefd-cdf2-4b1… af893e86-8e9… <chr>    <list> <lgl [1]>      
    ##  8 d68a8b48-ab… 83bbeaaf-f5e0-42a… 3a5dbf8a-9b3… <chr>    <list> <lgl [1]>      
    ##  9 e88a8e7c-05… 02e1d36f-3019-49c… 16876983-d45… <chr>    <list> <lgl [1]>      
    ## 10 5fa72b3e-99… 5451683b-f184-4bd… 16876983-d45… <chr>    <list> <lgl [1]>      
    ## # ℹ 2,117 more rows
    ## # ℹ 30 more variables: cell_count <int>, cell_type <list>, citation <chr>,
    ## #   default_embedding <chr>, development_stage <list>, disease <list>,
    ## #   embeddings <list>, explorer_url <chr>, feature_biotype <list>,
    ## #   feature_count <int>, feature_reference <list>,
    ## #   genetic_perturbation_strategy <lgl>, is_pre_analysis <lgl>,
    ## #   is_primary_data <list>, mean_genes_per_cell <dbl>, organism <list>, …

``` r

files(db)
```

    ## # A tibble: 2,167 × 4
    ##    dataset_id                              filesize filetype url                
    ##    <chr>                                      <dbl> <chr>    <chr>              
    ##  1 ed419b4e-db9b-40f1-8593-68fdf8dfb076  1433774383 H5AD     https://datasets.c…
    ##  2 aad97cb5-f375-45ef-ae9d-178e7f5d5180   806170493 H5AD     https://datasets.c…
    ##  3 8f10185b-e0b3-46a5-8706-7f1799225d79  3168171879 H5AD     https://datasets.c…
    ##  4 359f7af4-87d4-4117-9d6c-ca4cfa1f3f0b  3480337646 H5AD     https://datasets.c…
    ##  5 11ef37ee-2173-458e-aab8-7fe35da8e47b   416349451 H5AD     https://datasets.c…
    ##  6 0129dbd9-a7d3-4f6b-96b9-1da155a93748 18859417847 H5AD     https://datasets.c…
    ##  7 00e5dedd-b9b7-43be-8c28-b0e5c6414a62  1393176026 H5AD     https://datasets.c…
    ##  8 d68a8b48-abf0-4bd5-8834-155d34ec448a  1896898431 H5AD     https://datasets.c…
    ##  9 e88a8e7c-0586-4690-8aa6-34efd7076f7a 33998142156 H5AD     https://datasets.c…
    ## 10 5fa72b3e-999e-4560-a105-391d109574da 33219989200 H5AD     https://datasets.c…
    ## # ℹ 2,157 more rows

Each of these resources has a unique primary identifier (e.g.,
`file_id`) as well as an identifier describing the relationship of the
resource to other components of the database (e.g., `dataset_id`). These
identifiers can be used to ‘join’ information across tables.

### Using `dplyr` to navigate data

A collection may have several datasets, and datasets may have several
files. For instance, here is the collection with the most datasets

``` r

collection_with_most_datasets <-
    datasets(db) |>
    count(collection_id, sort = TRUE) |>
    slice(1)
```

We can find out about this collection by joining with the
[`collections()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md)
table.

``` r

left_join(
    collection_with_most_datasets |> select(collection_id),
    collections(db),
    by = "collection_id"
) |> glimpse()
```

    ## Rows: 1
    ## Columns: 19
    ## $ collection_id         <chr> "283d65eb-dd53-496d-adb7-7570c7caa443"
    ## $ collection_version_id <chr> "36a4e4dd-d0f4-4b4a-bea8-a173ddafb13f"
    ## $ collection_url        <chr> "https://cellxgene.cziscience.com/collections/28…
    ## $ consortia             <list> <"BRAIN Initiative", "CZI Cell Science">
    ## $ contact_email         <chr> "kimberly.siletti@ki.se"
    ## $ contact_name          <chr> "Kimberly Siletti"
    ## $ curator_name          <chr> "James Chaffer"
    ## $ description           <chr> "First draft atlas of human brain transcriptomic…
    ## $ doi                   <chr> "10.1126/science.add7046"
    ## $ is_pre_analysis       <lgl> FALSE
    ## $ links                 <list> [["", "RAW_DATA", "http://data.nemoarchive.org/b…
    ## $ name                  <chr> "Human Brain Cell Atlas v1.0"
    ## $ publisher_metadata    <list> [[["Siletti", "Kimberly"], ["Hodge", "Rebecca"]…
    ## $ revising_in           <lgl> NA
    ## $ revision_of           <lgl> NA
    ## $ visibility            <chr> "PUBLIC"
    ## $ created_at            <date> 2026-06-10
    ## $ published_at          <date> 2022-12-09
    ## $ revised_at            <date> 2026-06-11

We can take a similar strategy to identify all datasets belonging to
this collection

``` r

left_join(
    collection_with_most_datasets |> select(collection_id),
    datasets(db),
    by = "collection_id"
)
```

    ## # A tibble: 138 × 36
    ##    collection_id   dataset_id dataset_version_id donor_id assay  batch_condition
    ##    <chr>           <chr>      <chr>              <list>   <list> <list>         
    ##  1 283d65eb-dd53-… ff7d15fa-… feb3418a-6b5c-4aa… <chr>    <list> <chr [1]>      
    ##  2 283d65eb-dd53-… fe1a73ab-… 36c0b289-8c37-401… <chr>    <list> <chr [1]>      
    ##  3 283d65eb-dd53-… fbf173f9-… 769be3db-d7a6-4e4… <chr>    <list> <chr [1]>      
    ##  4 283d65eb-dd53-… fa554686-… df9c10d1-a600-467… <chr>    <list> <chr [1]>      
    ##  5 283d65eb-dd53-… f9034091-… c835d94f-cbde-4b2… <chr>    <list> <chr [1]>      
    ##  6 283d65eb-dd53-… f8dda921-… 16f5886b-f2d0-4a4… <chr>    <list> <chr [1]>      
    ##  7 283d65eb-dd53-… f7d003d4-… d0fe7a36-36d5-407… <chr>    <list> <chr [1]>      
    ##  8 283d65eb-dd53-… f6d9f2ad-… 1b020af5-6352-43c… <chr>    <list> <chr [1]>      
    ##  9 283d65eb-dd53-… f5a04dff-… 99a7f50b-40a2-4ac… <chr>    <list> <chr [1]>      
    ## 10 283d65eb-dd53-… f502c312-… d7f9e68a-e253-4ce… <chr>    <list> <chr [1]>      
    ## # ℹ 128 more rows
    ## # ℹ 30 more variables: cell_count <int>, cell_type <list>, citation <chr>,
    ## #   default_embedding <chr>, development_stage <list>, disease <list>,
    ## #   embeddings <list>, explorer_url <chr>, feature_biotype <list>,
    ## #   feature_count <int>, feature_reference <list>,
    ## #   genetic_perturbation_strategy <lgl>, is_pre_analysis <lgl>,
    ## #   is_primary_data <list>, mean_genes_per_cell <dbl>, organism <list>, …

### `facets()` provides information on ‘levels’ present in specific columns

Notice that some columns are ‘lists’ rather than atomic vectors like
‘character’ or ‘integer’.

``` r

datasets(db) |>
    select(where(is.list))
```

    ## # A tibble: 2,127 × 16
    ##    donor_id    assay      batch_condition cell_type   development_stage disease
    ##    <list>      <list>     <list>          <list>      <list>            <list> 
    ##  1 <chr [6]>   <list [1]> <lgl [1]>       <list [4]>  <list [5]>        <list> 
    ##  2 <chr [6]>   <list [1]> <lgl [1]>       <list [1]>  <list [5]>        <list> 
    ##  3 <chr [6]>   <list [1]> <lgl [1]>       <list [2]>  <list [5]>        <list> 
    ##  4 <chr [6]>   <list [1]> <lgl [1]>       <list [1]>  <list [5]>        <list> 
    ##  5 <chr [6]>   <list [1]> <lgl [1]>       <list [1]>  <list [5]>        <list> 
    ##  6 <chr [6]>   <list [1]> <lgl [1]>       <list [6]>  <list [5]>        <list> 
    ##  7 <chr [6]>   <list [1]> <lgl [1]>       <list [2]>  <list [5]>        <list> 
    ##  8 <chr [24]>  <list [1]> <lgl [1]>       <list [39]> <list [16]>       <list> 
    ##  9 <chr [101]> <list [1]> <lgl [1]>       <list [27]> <list [25]>       <list> 
    ## 10 <chr [101]> <list [1]> <lgl [1]>       <list [27]> <list [25]>       <list> 
    ## # ℹ 2,117 more rows
    ## # ℹ 10 more variables: embeddings <list>, feature_biotype <list>,
    ## #   feature_reference <list>, is_primary_data <list>, organism <list>,
    ## #   self_reported_ethnicity <list>, sex <list>, spatial <list>,
    ## #   suspension_type <list>, tissue <list>

This indicates that at least some of the datasets had more than one type
of `assay`, `cell_type`, etc. The
[`facets()`](https://mtmorgan.github.io/cellxgenedp/reference/facets.md)
function provides a convenient way of discovering possible levels of
each column, e.g., `assay`, `organism`, `self_reported_ethnicity`, or
`sex`, and the number of datasets with each label.

``` r

facets(db, "assay")
```

    ## # A tibble: 50 × 4
    ##    facet label                             ontology_term_id     n
    ##    <chr> <chr>                             <chr>            <int>
    ##  1 assay 10x 3' v3                         EFO:0009922       1035
    ##  2 assay 10x 3' v2                         EFO:0009899        475
    ##  3 assay Visium Spatial Gene Expression V1 EFO:0022857        350
    ##  4 assay Slide-seqV2                       EFO:0030062        240
    ##  5 assay 10x 5' v1                         EFO:0011025        144
    ##  6 assay 10x 5' v2                         EFO:0009900        114
    ##  7 assay 10x multiome                      EFO:0030059        106
    ##  8 assay Smart-seq2                        EFO:0008931        102
    ##  9 assay sci-RNA-seq3                      EFO:0030028         81
    ## 10 assay 10x 5' transcription profiling    EFO:0030004         41
    ## # ℹ 40 more rows

``` r

facets(db, "self_reported_ethnicity")
```

    ## # A tibble: 44 × 4
    ##    facet                   label                          ontology_term_id     n
    ##    <chr>                   <chr>                          <chr>            <int>
    ##  1 self_reported_ethnicity unknown                        unknown           1437
    ##  2 self_reported_ethnicity na                             na                 534
    ##  3 self_reported_ethnicity Asian                          HANCESTRO:0847     296
    ##  4 self_reported_ethnicity African American               HANCESTRO:0568     209
    ##  5 self_reported_ethnicity European American              HANCESTRO:0590     182
    ##  6 self_reported_ethnicity Hispanic or Latin              HANCESTRO:0612     177
    ##  7 self_reported_ethnicity British                        HANCESTRO:0462      63
    ##  8 self_reported_ethnicity Hispanic or Latin || Native A… HANCESTRO:0612 …    50
    ##  9 self_reported_ethnicity South Asian                    HANCESTRO:0848      39
    ## 10 self_reported_ethnicity Middle Eastern                 HANCESTRO:0852      29
    ## # ℹ 34 more rows

``` r

facets(db, "sex")
```

    ## # A tibble: 4 × 4
    ##   facet label   ontology_term_id     n
    ##   <chr> <chr>   <chr>            <int>
    ## 1 sex   male    PATO:0000384      1530
    ## 2 sex   female  PATO:0000383      1329
    ## 3 sex   unknown unknown            387
    ## 4 sex   na      na                   5

### Filtering faceted columns

Suppose we were interested in finding datasets from the 10x 3’ v3 assay
(`ontology_term_id` of `EFO:0009922`) containing individuals of African
American ethnicity, and female sex. Use the
[`facets_filter()`](https://mtmorgan.github.io/cellxgenedp/reference/facets.md)
utility function to filter data sets as needed

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
```

    ## # A tibble: 1 × 1
    ##   total_cell_count
    ##              <int>
    ## 1         45752549

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
```

    ## # A tibble: 54 × 19
    ##    collection_id    collection_version_id collection_url consortia contact_email
    ##    <chr>            <chr>                 <chr>          <list>    <chr>        
    ##  1 3a5dbf8a-9b3e-4… c656236c-fc37-4470-a… https://cellx… <chr [1]> xinsun@ucsd.…
    ##  2 a98b828a-622a-4… 5ff5602b-90fb-4004-a… https://cellx… <chr [1]> markusbi@med…
    ##  3 7c4552fd-8a6d-4… b7be7f62-1c8a-421d-8… https://cellx… <lgl [1]> icobos@stanf…
    ##  4 b953c942-f5d8-4… 1916410f-d8e0-4486-9… https://cellx… <lgl [1]> icobos@stanf…
    ##  5 4195ab4c-20bd-4… f7bfd628-aaeb-4eb8-a… https://cellx… <chr [1]> nnavin@mdand…
    ##  6 a96133de-e951-4… 39802ad3-568b-4637-a… https://cellx… <chr [1]> jklugham@bro…
    ##  7 fe0e718d-2ee9-4… 0b69d863-f3aa-455c-b… https://cellx… <lgl [1]> erosen@bidmc…
    ##  8 77f9d7e9-5675-4… 4ee03caa-4822-432a-a… https://cellx… <lgl [1]> claire.gusta…
    ##  9 5e143645-177c-4… aa0f3f48-80b0-4f75-9… https://cellx… <chr [1]> orr@broadins…
    ## 10 3b8b7fec-ed65-4… e12c085a-23cc-4fcc-9… https://cellx… <lgl [1]> karakashet@c…
    ## # ℹ 44 more rows
    ## # ℹ 14 more variables: contact_name <chr>, curator_name <chr>,
    ## #   description <chr>, doi <chr>, is_pre_analysis <lgl>, links <list>,
    ## #   name <chr>, publisher_metadata <list>, revising_in <lgl>,
    ## #   revision_of <lgl>, visibility <chr>, created_at <date>,
    ## #   published_at <date>, revised_at <date>

### Publication and other external data

Many collections include publication information and other external
data. This information is available in the return value of
[`collections()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md),
but the helper function
[`publisher_metadata()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md),
[`authors()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md),
and
[`links()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md)
may facilitate access.

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
```

    ## Rows: 1
    ## Columns: 19
    ## $ collection_id         <chr> "c9706a92-0e5f-46c1-96d8-20e42467f287"
    ## $ collection_version_id <chr> "86834318-363f-41bf-b852-0879d386b473"
    ## $ collection_url        <chr> "https://cellxgene.cziscience.com/collections/c9…
    ## $ consortia             <list> "CZI Cell Science"
    ## $ contact_email         <chr> "hnakshat@iupui.edu"
    ## $ contact_name          <chr> "Harikrishna Nakshatri"
    ## $ curator_name          <chr> "Jennifer Yu-Sheng Chien"
    ## $ description           <chr> "Single-cell RNA sequencing (scRNA-seq) is an ev…
    ## $ doi                   <chr> "10.1016/j.xcrm.2021.100219"
    ## $ is_pre_analysis       <lgl> FALSE
    ## $ links                 <list> [["", "RAW_DATA", "https://explore.data.humancel…
    ## $ name                  <chr> "A single-cell atlas of the healthy breast tiss…
    ## $ publisher_metadata    <list> [[["Bhat-Nakshatri", "Poornima"], ["Gao", "Hongy…
    ## $ revising_in           <lgl> NA
    ## $ revision_of           <lgl> NA
    ## $ visibility            <chr> "PUBLIC"
    ## $ created_at            <date> 2026-06-10
    ## $ published_at          <date> 2021-03-25
    ## $ revised_at            <date> 2026-06-11

Use the `collection_id` to extract publisher metadata (including a DOI
if available) and author information

``` r

collection_id_of_interest <- pull(collection_of_interest, "collection_id")
publisher_metadata(db) |>
    filter(collection_id == collection_id_of_interest) |>
    glimpse()
```

    ## Rows: 1
    ## Columns: 9
    ## $ collection_id   <chr> "c9706a92-0e5f-46c1-96d8-20e42467f287"
    ## $ name            <chr> "A single-cell atlas of the healthy breast tissues rev…
    ## $ is_preprint     <lgl> FALSE
    ## $ journal         <chr> "Cell Reports Medicine"
    ## $ published_at    <date> 2021-03-01
    ## $ published_year  <int> 2021
    ## $ published_month <int> 3
    ## $ published_day   <int> 1
    ## $ doi             <chr> NA

``` r

authors(db) |>
    filter(collection_id == collection_id_of_interest)
```

    ## # A tibble: 12 × 4
    ##    collection_id                        family         given       consortium
    ##    <chr>                                <chr>          <chr>       <chr>     
    ##  1 c9706a92-0e5f-46c1-96d8-20e42467f287 Bhat-Nakshatri Poornima    NA        
    ##  2 c9706a92-0e5f-46c1-96d8-20e42467f287 Gao            Hongyu      NA        
    ##  3 c9706a92-0e5f-46c1-96d8-20e42467f287 Sheng          Liu         NA        
    ##  4 c9706a92-0e5f-46c1-96d8-20e42467f287 McGuire        Patrick C.  NA        
    ##  5 c9706a92-0e5f-46c1-96d8-20e42467f287 Xuei           Xiaoling    NA        
    ##  6 c9706a92-0e5f-46c1-96d8-20e42467f287 Wan            Jun         NA        
    ##  7 c9706a92-0e5f-46c1-96d8-20e42467f287 Liu            Yunlong     NA        
    ##  8 c9706a92-0e5f-46c1-96d8-20e42467f287 Althouse       Sandra K.   NA        
    ##  9 c9706a92-0e5f-46c1-96d8-20e42467f287 Colter         Austyn      NA        
    ## 10 c9706a92-0e5f-46c1-96d8-20e42467f287 Sandusky       George      NA        
    ## 11 c9706a92-0e5f-46c1-96d8-20e42467f287 Storniolo      Anna Maria  NA        
    ## 12 c9706a92-0e5f-46c1-96d8-20e42467f287 Nakshatri      Harikrishna NA

Collections may have links to additional external data, in this case a
DOI and two links to `RAW_DATA`.

``` r

external_links <- links(db)
external_links
```

    ## # A tibble: 1,205 × 4
    ##    collection_id                        link_name       link_type link_url      
    ##    <chr>                                <chr>           <chr>     <chr>         
    ##  1 af893e86-8e9f-41f1-a474-ef05359b1fb7 NA              OTHER     https://retin…
    ##  2 af893e86-8e9f-41f1-a474-ef05359b1fb7 NA              RAW_DATA  https://explo…
    ##  3 af893e86-8e9f-41f1-a474-ef05359b1fb7 GSE226108       RAW_DATA  https://www.n…
    ##  4 3a5dbf8a-9b3e-4309-b4c5-d8a024f83734 NA              OTHER     https://data-…
    ##  5 ad10cef8-9c6c-488f-9b50-d252d49b6837 GSE241468       RAW_DATA  https://www.n…
    ##  6 ad10cef8-9c6c-488f-9b50-d252d49b6837 NA              OTHER     https://githu…
    ##  7 ad10cef8-9c6c-488f-9b50-d252d49b6837 NA              OTHER     https://zenod…
    ##  8 7f7fdf50-aa0e-4a6f-979c-53655cac9d5d NA              OTHER     https://www.i…
    ##  9 7f7fdf50-aa0e-4a6f-979c-53655cac9d5d EGAD00001015692 RAW_DATA  https://ega-a…
    ## 10 35928d1c-36fc-4f93-9a8d-0b921ab41745 Allen Brain Map OTHER     https://knowl…
    ## # ℹ 1,195 more rows

``` r

external_links |>
    count(link_type)
```

    ## # A tibble: 5 × 2
    ##   link_type       n
    ##   <chr>       <int>
    ## 1 DATA_SOURCE    97
    ## 2 LAB_WEBSITE    69
    ## 3 OTHER         507
    ## 4 PROTOCOL       67
    ## 5 RAW_DATA      465

``` r

external_links |>
    filter(collection_id == collection_id_of_interest)
```

    ## # A tibble: 2 × 4
    ##   collection_id                        link_name link_type link_url             
    ##   <chr>                                <chr>     <chr>     <chr>                
    ## 1 c9706a92-0e5f-46c1-96d8-20e42467f287 NA        RAW_DATA  https://explore.data…
    ## 2 c9706a92-0e5f-46c1-96d8-20e42467f287 NA        RAW_DATA  https://www.ncbi.nlm…

Conversely, knowledge of a DOI, etc., can be used to discover details of
the corresponding collection.

``` r

doi_of_interest <- "https://doi.org/10.1016/j.stem.2018.12.011"
links(db) |>
    filter(link_url == doi_of_interest) |>
    left_join(collections(db), by = "collection_id") |>
    glimpse()
```

    ## Rows: 1
    ## Columns: 22
    ## $ collection_id         <chr> "b1a879f6-5638-48d3-8f64-f6592c1b1561"
    ## $ link_name             <chr> "PSC-ATO protocol"
    ## $ link_type             <chr> "PROTOCOL"
    ## $ link_url              <chr> "https://doi.org/10.1016/j.stem.2018.12.011"
    ## $ collection_version_id <chr> "d8856f5e-149a-431e-bb62-3cd32f6b76c8"
    ## $ collection_url        <chr> "https://cellxgene.cziscience.com/collections/b1…
    ## $ consortia             <list> <"CZI Cell Science", "Wellcome HCA Strategic Sci…
    ## $ contact_email         <chr> "st9@sanger.ac.uk"
    ## $ contact_name          <chr> "Sarah A. Teichmann"
    ## $ curator_name          <chr> "Jennifer Yu-Sheng Chien"
    ## $ description           <chr> "Single-cell genomics studies have decoded the i…
    ## $ doi                   <chr> "10.1126/science.abo0510"
    ## $ is_pre_analysis       <lgl> FALSE
    ## $ links                 <list> [["scVI Models", "DATA_SOURCE", "https://develop…
    ## $ name                  <chr> "Mapping the developing human immune system acro…
    ## $ publisher_metadata    <list> [[["Suo", "Chenqu"], ["Dann", "Emma"], ["Goh", "…
    ## $ revising_in           <lgl> NA
    ## $ revision_of           <lgl> NA
    ## $ visibility            <chr> "PUBLIC"
    ## $ created_at            <date> 2026-06-10
    ## $ published_at          <date> 2022-10-04
    ## $ revised_at            <date> 2026-06-11

## Visualizing data in `cellxgene`

Visualization is straight-forward once `dataset_id` is available. For
example, to visualize the first dataset in `african_american_female`,
use

``` r

african_american_female |>
    ## use criteria to identify a single dataset (here just the
    ## 'first' dataset), then visualize
    slice(1) |>
    datasets_visualize()
```

Visualization is an interactive process, so
[`datasets_visualize()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md)
will only open up to 5 browser tabs per call.

## File download and use

Datasets usually contain `H5AD` (files produced by the python AnnData
module), and `Rds` (serialized files produced by the *R* Seurat
package). The `Rds` files may be unreadable if the version of Seurat
used to create the file is different from the version used to read the
file. We therefore focus on the `H5AD` files.

For illustration, we find all files associated with studies with African
American females

download one of our selected files.

``` r

selected_files <-
    left_join(
        african_american_female |> select(dataset_id),
        files(db),
        by = "dataset_id"
    )
```

And then choose a single dataset and its H5AD file for download

``` r

local_file <-
    selected_files |>
    filter(
        dataset_id == "de985818-285f-4f59-9dbd-d74968fddba3",
        filetype == "H5AD"
    ) |>
    files_download(dry.run = FALSE)
basename(local_file)
```

    ## [1] "8bd3e220-f9dd-4088-ba39-0c72767b5ed9.h5ad"

These are downloaded to a local cache (use the internal function
`cellxgenedp:::.cellxgenedb_cache_path()` for the location of the
cache), so the process is only time-consuming the first time.

`H5AD` files can be converted to *R* / *Bioconductor* objects using the
[zellkonverter](https://bioconductor.org/packages/zelkonverter) package.

``` r

h5ad <- readH5AD(local_file, use_hdf5 = TRUE, reader = "R")
```

    ## For native R and reading and writing of H5AD files, an R <AnnData> object, and
    ## conversion to <SingleCellExperiment> or <Seurat> objects, check out the
    ## anndataR package:
    ## ℹ Install it from Bioconductor with `BiocManager::install("anndataR")`
    ## ℹ See more at <https://bioconductor.org/packages/anndataR/>
    ## This message is displayed once per session.

``` r

h5ad
```

    ## class: SingleCellExperiment 
    ## dim: 32397 31696 
    ## metadata(8): citation default_embedding ... schema_version title
    ## assays(1): X
    ## rownames(32397): ENSG00000243485 ENSG00000237613 ... ENSG00000277475
    ##   ENSG00000268674
    ## rowData names(6): feature_is_filtered feature_name ... feature_length
    ##   feature_type
    ## colnames(31696): CMGpool_AAACCCAAGGACAACC CMGpool_AAACCCACAATCTCTT ...
    ##   K109064_TTTGTTGGTTGCATCA K109064_TTTGTTGGTTGGACCC
    ## colData names(43): mapped_reference_annotation donor_id ...
    ##   development_stage observation_joinid
    ## reducedDimNames(3): X_pca X_tsne X_umap
    ## mainExpName: NULL
    ## altExpNames(0):

The `SingleCellExperiment` object is a matrix-like object with rows
corresponding to genes and columns to cells. Thus we can easily explore
the cells present in the data.

``` r

h5ad |>
    colData(h5ad) |>
    as_tibble() |>
    count(sex, donor_id)
```

    ## # A tibble: 7 × 3
    ##   sex    donor_id                     n
    ##   <fct>  <fct>                    <int>
    ## 1 female D1                        2303
    ## 2 female D2                         864
    ## 3 female D3                        2517
    ## 4 female D4                        1771
    ## 5 female D5                        2244
    ## 6 female D11                       7454
    ## 7 female pooled [D9,D7,D8,D10,D6] 14543

## Next steps

The [Orchestrating Single-Cell Analysis with
Bioconductor](https://bioconductor.org/books/OSCA) online resource
provides an excellent introduction to analysis and visualization of
single-cell data in *R* / *Bioconductor*. Extensive opportunities for
working with AnnData objects in *R* but using the native python
interface are briefly described in, e.g.,
[`?AnnData2SCE`](https://rdrr.io/pkg/zellkonverter/man/AnnData-Conversion.html)
help page of
[zellkonverter](https://bioconductor.org/packages/zelkonverter).

The [hca](https://bioconductor.org/packages/hca) package provides
programmatic access to the Human Cell Atlas [data
portal](https://data.humancellatlas.org/explore), allowing retrieval of
primary as well as derived single-cell data files.

## API changes

Data access provided by CELLxGENE has changed to a new ‘Discover’
[API](https://api.cellxgene.cziscience.com/curation/ui/). The main
functionality of the
[cellxgenedp](https://mtmorgan.github.io/cellxgenedp) package has not
changed, but specific columns have been removed, replaced or added, as
follows:

[`collections()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md)

- Removed: `access_type`, `data_submission_policy_version`
- Replaced: `updated_at` replaced with `revised_at`
- Added: `collection_version_id`, `collection_url`, `doi`,
  `revising_in`, `revision_of`

[`datasets()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md)

- Removed: `is_valid`, `processing_status`, `published`, `revision`,
  `created_at`
- Replaced: `dataset_deployments` replaced with `explorer_url`, `name`
  replaced with `title`, `updated_at` replaced with `revised_at`
- Added: `dataset_version_id`, `batch_condition`,
  `x_approximate_distribution`

[`files()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md)

- Removed: `file_id`, `filename`, `s3_uri`, `user_submitted`,
  `created_at`, `updated_at`
- Added: `filesize`, `url`

## Session info

    ## R version 4.6.0 (2026-04-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    ##  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    ##  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    ## [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ##  [1] cellxgenedp_1.17.1          dplyr_1.2.1                
    ##  [3] SingleCellExperiment_1.34.0 SummarizedExperiment_1.42.0
    ##  [5] Biobase_2.72.0              GenomicRanges_1.64.0       
    ##  [7] Seqinfo_1.2.0               IRanges_2.46.0             
    ##  [9] S4Vectors_0.50.1            BiocGenerics_0.58.1        
    ## [11] generics_0.1.4              MatrixGenerics_1.24.0      
    ## [13] matrixStats_1.5.0           zellkonverter_1.22.0       
    ## [15] BiocStyle_2.40.0           
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] dir.expiry_1.20.0   xfun_0.58           bslib_0.11.0       
    ##  [4] htmlwidgets_1.6.4   rhdf5_2.56.0        lattice_0.22-9     
    ##  [7] rhdf5filters_1.24.0 vctrs_0.7.3         rjsoncons_1.3.3    
    ## [10] tools_4.6.0         curl_7.1.0          parallel_4.6.0     
    ## [13] tibble_3.3.1        pkgconfig_2.0.3     Matrix_1.7-5       
    ## [16] desc_1.4.3          lifecycle_1.0.5     compiler_4.6.0     
    ## [19] textshaping_1.0.5   httpuv_1.6.17       htmltools_0.5.9    
    ## [22] sass_0.4.10         yaml_2.3.12         later_1.4.8        
    ## [25] pkgdown_2.2.0       pillar_1.11.1       jquerylib_0.1.4    
    ## [28] DT_0.34.0           DelayedArray_0.38.2 cachem_1.1.0       
    ## [31] abind_1.4-8         mime_0.13           basilisk_1.24.0    
    ## [34] tidyselect_1.2.1    digest_0.6.39       bookdown_0.46      
    ## [37] fastmap_1.2.0       grid_4.6.0          cli_3.6.6          
    ## [40] SparseArray_1.12.2  magrittr_2.0.5      S4Arrays_1.12.0    
    ## [43] h5mread_1.4.0       utf8_1.2.6          withr_3.0.2        
    ## [46] promises_1.5.0      filelock_1.0.3      rmarkdown_2.31     
    ## [49] XVector_0.52.0      httr_1.4.8          otel_0.2.0         
    ## [52] reticulate_1.46.0   ragg_1.5.2          png_0.1-9          
    ## [55] HDF5Array_1.40.0    shiny_1.13.0        evaluate_1.0.5     
    ## [58] knitr_1.51          rlang_1.2.0         Rcpp_1.1.1-1.1     
    ## [61] xtable_1.8-8        glue_1.8.1          BiocManager_1.30.27
    ## [64] jsonlite_2.0.0      Rhdf5lib_2.0.0      R6_2.6.1           
    ## [67] systemfonts_1.3.2   fs_2.1.0
