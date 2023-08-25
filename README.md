
NOTE: The interface to CELLxGENE has changed; versions of
[cellxgenedp](https://bioconductor.org/packages/cellxgenedp) prior to
1.4.1 / 1.5.2 will cease to work when CELLxGENE removes the previous
interface. See the vignette section ‘API changes’ for additional
details.

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
#> number of collections(): 152
#> number of datasets(): 910
#> number of files(): 1802
```

The portal organizes data hierarchically, with ‘collections’ (research
studies, approximately), ‘datasets’, and ‘files’. Discover data using
the corresponding functions.

``` r
collections(db)
#> # A tibble: 152 × 18
#>    collection_id    collection_version_id collection_url consortia contact_email
#>    <chr>            <chr>                 <chr>          <list>    <chr>        
#>  1 e75342a8-0f3b-4… 2d569157-4335-40d6-a… https://cellx… <list>    nhuebner@mdc…
#>  2 661a402a-2a5a-4… 626b26f4-a84c-4f31-8… https://cellx… <lgl [1]> rv4@sanger.a…
#>  3 367d95c0-0eb0-4… 4216ddce-94c0-4fdc-9… https://cellx… <list>    edl@allenins…
#>  4 af893e86-8e9f-4… fc8a8009-02f0-4084-9… https://cellx… <list>    ruichen@bcm.…
#>  5 48d354f5-a5ca-4… 54caf53d-0a4d-4874-9… https://cellx… <list>    Nathan.Salom…
#>  6 793fdaec-5067-4… b4431833-4155-48d7-8… https://cellx… <list>    m.a.haniffa@…
#>  7 13d1c580-4b17-4… c7b93415-bf09-45df-9… https://cellx… <list>    my4@sanger.a…
#>  8 fbc5881f-1ee3-4… 4f2da30d-407b-4c94-8… https://cellx… <list>    Douglas.Stra…
#>  9 c114c20f-1ef4-4… 871e2180-9ac4-4025-8… https://cellx… <lgl [1]> shendure@uw.…
#> 10 c8565c6a-01a1-4… 07bfe4f4-61bc-463c-a… https://cellx… <list>    carmen.sando…
#> # ℹ 142 more rows
#> # ℹ 13 more variables: contact_name <chr>, curator_name <chr>,
#> #   description <chr>, doi <chr>, links <list>, name <chr>,
#> #   publisher_metadata <list>, revising_in <lgl>, revision_of <lgl>,
#> #   visibility <chr>, created_at <date>, published_at <date>, revised_at <date>

datasets(db)
#> # A tibble: 910 × 24
#>    dataset_id   dataset_version_id collection_id donor_id assay  batch_condition
#>    <chr>        <chr>              <chr>         <list>   <list> <list>         
#>  1 f7995301-75… 0a4f9a00-6f75-4ff… e75342a8-0f3… <list>   <list> <lgl [1]>      
#>  2 ed2b673b-02… 61640b98-af3d-4b9… e75342a8-0f3… <list>   <list> <lgl [1]>      
#>  3 bdf69f8d-5a… f40a4b36-e499-48f… e75342a8-0f3… <list>   <list> <lgl [1]>      
#>  4 9434b020-de… 2a96a174-e168-40f… e75342a8-0f3… <list>   <list> <lgl [1]>      
#>  5 83b5e943-a1… 1e9414d2-e347-467… e75342a8-0f3… <list>   <list> <lgl [1]>      
#>  6 65badd7a-92… ae6ef28f-cabc-48d… e75342a8-0f3… <list>   <list> <lgl [1]>      
#>  7 1252c5fb-94… 65df6878-8cc6-49c… e75342a8-0f3… <list>   <list> <lgl [1]>      
#>  8 1062c0f2-2a… 323243d7-0c21-461… e75342a8-0f3… <list>   <list> <lgl [1]>      
#>  9 0fdb6122-46… 45dd32d7-00ff-4a1… e75342a8-0f3… <list>   <list> <lgl [1]>      
#> 10 be46dfdc-0f… 7469da86-82cf-4d7… 661a402a-2a5… <list>   <list> <lgl [1]>      
#> # ℹ 900 more rows
#> # ℹ 18 more variables: cell_count <int>, cell_type <list>,
#> #   development_stage <list>, disease <list>, explorer_url <chr>,
#> #   is_primary_data <list>, mean_genes_per_cell <dbl>, organism <list>,
#> #   schema_version <chr>, self_reported_ethnicity <list>, sex <list>,
#> #   suspension_type <list>, tissue <list>, title <chr>, tombstone <lgl>,
#> #   x_approximate_distribution <chr>, published_at <date>, revised_at <date>

files(db)
#> # A tibble: 1,802 × 4
#>    dataset_id                             filesize filetype url                 
#>    <chr>                                     <dbl> <chr>    <chr>               
#>  1 f7995301-7551-4e1d-8396-ffe3c9497ace 3255625301 H5AD     https://datasets.ce…
#>  2 f7995301-7551-4e1d-8396-ffe3c9497ace 3234403317 RDS      https://datasets.ce…
#>  3 ed2b673b-0279-454a-998c-3eec361edf54 1010106545 H5AD     https://datasets.ce…
#>  4 ed2b673b-0279-454a-998c-3eec361edf54  967955201 RDS      https://datasets.ce…
#>  5 bdf69f8d-5a96-4d6f-a9f5-9ee0e33597b7   35165722 H5AD     https://datasets.ce…
#>  6 bdf69f8d-5a96-4d6f-a9f5-9ee0e33597b7   26133065 RDS      https://datasets.ce…
#>  7 9434b020-de42-43eb-bcc4-542b2be69015  860641548 H5AD     https://datasets.ce…
#>  8 9434b020-de42-43eb-bcc4-542b2be69015  934357743 RDS      https://datasets.ce…
#>  9 83b5e943-a1d5-4164-b3f2-f7a37f01b524  134378259 H5AD     https://datasets.ce…
#> 10 83b5e943-a1d5-4164-b3f2-f7a37f01b524  141856536 RDS      https://datasets.ce…
#> # ℹ 1,792 more rows
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
#> Columns: 18
#> $ collection_id         <chr> "283d65eb-dd53-496d-adb7-7570c7caa443"
#> $ collection_version_id <chr> "ef0e3221-2487-48e3-bfac-69e9e2428b49"
#> $ collection_url        <chr> "https://cellxgene.cziscience.com/collections/28…
#> $ consortia             <list> ["BRAIN Initiative"]
#> $ contact_email         <chr> "kimberly.siletti@ki.se"
#> $ contact_name          <chr> "Kimberly Siletti"
#> $ curator_name          <chr> "James Chaffer"
#> $ description           <chr> "The human brain directs a wide range of complex…
#> $ doi                   <chr> "10.1101/2022.10.12.511898"
#> $ links                 <list> [["", "RAW_DATA", "http://data.nemoarchive.org/b…
#> $ name                  <chr> "Transcriptomic diversity of cell types across …
#> $ publisher_metadata    <list> [[["Siletti", "Kimberly"], ["Hodge", "Rebecca"],…
#> $ revising_in           <lgl> NA
#> $ revision_of           <lgl> NA
#> $ visibility            <chr> "PUBLIC"
#> $ created_at            <date> 2023-07-19
#> $ published_at          <date> 2022-12-09
#> $ revised_at            <date> 2023-08-23
```

We can take a similar strategy to identify all datasets belonging to
this collection

``` r
left_join(
    collection_with_most_datasets |> select(collection_id),
    datasets(db),
    by = "collection_id"
)
#> # A tibble: 139 × 24
#>    collection_id   dataset_id dataset_version_id donor_id assay  batch_condition
#>    <chr>           <chr>      <chr>              <list>   <list> <list>         
#>  1 283d65eb-dd53-… ff7d15fa-… ad4f40b1-ad1b-43e… <list>   <list> <list [1]>     
#>  2 283d65eb-dd53-… fe1a73ab-… ca8e9e3a-852f-487… <list>   <list> <list [1]>     
#>  3 283d65eb-dd53-… fbf173f9-… 3cd2b19b-7bda-4ad… <list>   <list> <list [1]>     
#>  4 283d65eb-dd53-… fa554686-… e05b2d3e-f9cb-460… <list>   <list> <list [1]>     
#>  5 283d65eb-dd53-… f9034091-… 3c1f250d-f27e-49a… <list>   <list> <list [1]>     
#>  6 283d65eb-dd53-… f8dda921-… de9cd660-638d-4b3… <list>   <list> <list [1]>     
#>  7 283d65eb-dd53-… f7d003d4-… e50d1b65-4ad1-48b… <list>   <list> <list [1]>     
#>  8 283d65eb-dd53-… f6d9f2ad-… a46aed38-e822-490… <list>   <list> <list [1]>     
#>  9 283d65eb-dd53-… f5a04dff-… 1c90c2fe-8f62-47d… <list>   <list> <list [1]>     
#> 10 283d65eb-dd53-… f502c312-… 166e3950-147b-4f4… <list>   <list> <list [1]>     
#> # ℹ 129 more rows
#> # ℹ 18 more variables: cell_count <int>, cell_type <list>,
#> #   development_stage <list>, disease <list>, explorer_url <chr>,
#> #   is_primary_data <list>, mean_genes_per_cell <dbl>, organism <list>,
#> #   schema_version <chr>, self_reported_ethnicity <list>, sex <list>,
#> #   suspension_type <list>, tissue <list>, title <chr>, tombstone <lgl>,
#> #   x_approximate_distribution <chr>, published_at <date>, revised_at <date>
```

## `facets()` provides information on ‘levels’ present in specific columns

Notice that some columns are ‘lists’ rather than atomic vectors like
‘character’ or ‘integer’.

``` r
datasets(db) |>
    select(where(is.list))
#> # A tibble: 910 × 12
#>    donor_id    assay      batch_condition cell_type   development_stage disease
#>    <list>      <list>     <list>          <list>      <list>            <list> 
#>  1 <list [79]> <list [2]> <lgl [1]>       <list [1]>  <list [10]>       <list> 
#>  2 <list [79]> <list [2]> <lgl [1]>       <list [1]>  <list [10]>       <list> 
#>  3 <list [66]> <list [2]> <lgl [1]>       <list [1]>  <list [10]>       <list> 
#>  4 <list [79]> <list [2]> <lgl [1]>       <list [2]>  <list [10]>       <list> 
#>  5 <list [79]> <list [2]> <lgl [1]>       <list [1]>  <list [10]>       <list> 
#>  6 <list [79]> <list [2]> <lgl [1]>       <list [10]> <list [10]>       <list> 
#>  7 <list [79]> <list [2]> <lgl [1]>       <list [1]>  <list [10]>       <list> 
#>  8 <list [79]> <list [2]> <lgl [1]>       <list [1]>  <list [10]>       <list> 
#>  9 <list [79]> <list [2]> <lgl [1]>       <list [2]>  <list [10]>       <list> 
#> 10 <list [13]> <list [3]> <lgl [1]>       <list [8]>  <list [8]>        <list> 
#> # ℹ 900 more rows
#> # ℹ 6 more variables: is_primary_data <list>, organism <list>,
#> #   self_reported_ethnicity <list>, sex <list>, suspension_type <list>,
#> #   tissue <list>
```

This indicates that at least some of the datasets had more than one type
of `assay`, `cell_type`, etc. The `facets()` function provides a
convenient way of discovering possible levels of each column, e.g.,
`assay`, `organism`, `self_reported_ethnicity`, or `sex`, and the number
of datasets with each label.

``` r
facets(db, "assay")
#> # A tibble: 33 × 4
#>    facet label                          ontology_term_id     n
#>    <chr> <chr>                          <chr>            <int>
#>  1 assay 10x 3' v3                      EFO:0009922        499
#>  2 assay 10x 3' v2                      EFO:0009899        229
#>  3 assay Slide-seqV2                    EFO:0030062        129
#>  4 assay 10x 5' v1                      EFO:0011025         69
#>  5 assay Smart-seq2                     EFO:0008931         62
#>  6 assay Visium Spatial Gene Expression EFO:0010961         56
#>  7 assay 10x multiome                   EFO:0030059         54
#>  8 assay 10x 5' v2                      EFO:0009900         17
#>  9 assay 10x 5' transcription profiling EFO:0030004         13
#> 10 assay Drop-seq                       EFO:0008722         12
#> # ℹ 23 more rows
facets(db, "self_reported_ethnicity")
#> # A tibble: 30 × 4
#>    facet                   label                          ontology_term_id     n
#>    <chr>                   <chr>                          <chr>            <int>
#>  1 self_reported_ethnicity European                       HANCESTRO:0005     431
#>  2 self_reported_ethnicity unknown                        unknown            311
#>  3 self_reported_ethnicity na                             na                 212
#>  4 self_reported_ethnicity Asian                          HANCESTRO:0008     130
#>  5 self_reported_ethnicity African American               HANCESTRO:0568      57
#>  6 self_reported_ethnicity Hispanic or Latin American     HANCESTRO:0014      41
#>  7 self_reported_ethnicity admixed ancestry               HANCESTRO:0306      28
#>  8 self_reported_ethnicity African American or Afro-Cari… HANCESTRO:0016      26
#>  9 self_reported_ethnicity multiethnic                    multiethnic         25
#> 10 self_reported_ethnicity Greater Middle Eastern  (Midd… HANCESTRO:0015      22
#> # ℹ 20 more rows
facets(db, "sex")
#> # A tibble: 3 × 4
#>   facet label   ontology_term_id     n
#>   <chr> <chr>   <chr>            <int>
#> 1 sex   male    PATO:0000384       772
#> 2 sex   female  PATO:0000383       554
#> 3 sex   unknown unknown             71
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
#> 1          3293238
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
#> # A tibble: 9 × 18
#>   collection_id     collection_version_id collection_url consortia contact_email
#>   <chr>             <chr>                 <chr>          <list>    <chr>        
#> 1 4195ab4c-20bd-4c… 62466cd5-fca8-4961-b… https://cellx… <list>    nnavin@mdand…
#> 2 b9fc3d70-5a72-44… b659b6b3-7663-41f8-8… https://cellx… <list>    bruce.aronow…
#> 3 625f6bf4-2f33-49… 47a89d52-954c-428a-a… https://cellx… <list>    a5wang@healt…
#> 4 a98b828a-622a-48… 2be54f40-4035-4c92-b… https://cellx… <list>    markusbi@med…
#> 5 bcb61471-2a44-4d… 346be1d3-d745-45f5-a… https://cellx… <list>    info@kpmp.org
#> 6 6b701826-37bb-43… fc5d2347-b859-4744-a… https://cellx… <list>    astreets@ber…
#> 7 62e8f058-9c37-48… 8fc72e6e-b4f8-4f64-8… https://cellx… <list>    chanj3@mskcc…
#> 8 b953c942-f5d8-43… d221209d-610d-47f0-b… https://cellx… <lgl [1]> icobos@stanf…
#> 9 c9706a92-0e5f-46… 184e8999-210d-47e5-a… https://cellx… <list>    hnakshat@iup…
#> # ℹ 13 more variables: contact_name <chr>, curator_name <chr>,
#> #   description <chr>, doi <chr>, links <list>, name <chr>,
#> #   publisher_metadata <list>, revising_in <lgl>, revision_of <lgl>,
#> #   visibility <chr>, created_at <date>, published_at <date>, revised_at <date>
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
#> Columns: 18
#> $ collection_id         <chr> "c9706a92-0e5f-46c1-96d8-20e42467f287"
#> $ collection_version_id <chr> "184e8999-210d-47e5-aaa8-56224a925a11"
#> $ collection_url        <chr> "https://cellxgene.cziscience.com/collections/c9…
#> $ consortia             <list> ["CZI Single-Cell Biology"]
#> $ contact_email         <chr> "hnakshat@iupui.edu"
#> $ contact_name          <chr> "Harikrishna Nakshatri"
#> $ curator_name          <chr> "Jennifer Yu-Sheng Chien"
#> $ description           <chr> "Single-cell RNA sequencing (scRNA-seq) is an ev…
#> $ doi                   <chr> "10.1016/j.xcrm.2021.100219"
#> $ links                 <list> [["", "RAW_DATA", "https://data.humancellatlas.o…
#> $ name                  <chr> "A single-cell atlas of the healthy breast tiss…
#> $ publisher_metadata    <list> [[["Bhat-Nakshatri", "Poornima"], ["Gao", "Hongy…
#> $ revising_in           <lgl> NA
#> $ revision_of           <lgl> NA
#> $ visibility            <chr> "PUBLIC"
#> $ created_at            <date> 2023-08-22
#> $ published_at          <date> 2021-03-25
#> $ revised_at            <date> 2023-08-22
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
#> $ doi             <chr> NA
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
#> # A tibble: 591 × 4
#>    collection_id                        link_name             link_type link_url
#>    <chr>                                <chr>                 <chr>     <chr>   
#>  1 e75342a8-0f3b-4ec5-8ee1-245a23e0f7cb <NA>                  OTHER     https:/…
#>  2 e75342a8-0f3b-4ec5-8ee1-245a23e0f7cb <NA>                  OTHER     https:/…
#>  3 e75342a8-0f3b-4ec5-8ee1-245a23e0f7cb <NA>                  RAW_DATA  https:/…
#>  4 661a402a-2a5a-4c71-9b05-b346c57bc451 Human scRNA-seq (E-M… RAW_DATA  https:/…
#>  5 661a402a-2a5a-4c71-9b05-b346c57bc451 Mouse scRNA-seq (E-M… RAW_DATA  https:/…
#>  6 661a402a-2a5a-4c71-9b05-b346c57bc451 Reproductive Cell At… OTHER     http://…
#>  7 661a402a-2a5a-4c71-9b05-b346c57bc451 VenTo Lab             LAB_WEBS… https:/…
#>  8 367d95c0-0eb0-4dae-8276-9407239421ee Nuclei Isolation fro… PROTOCOL  https:/…
#>  9 367d95c0-0eb0-4dae-8276-9407239421ee Human Tissue Slicing… PROTOCOL  https:/…
#> 10 367d95c0-0eb0-4dae-8276-9407239421ee NeMo Analytics - ind… OTHER     https:/…
#> # ℹ 581 more rows
external_links |>
    count(link_type)
#> # A tibble: 5 × 2
#>   link_type       n
#>   <chr>       <int>
#> 1 DATA_SOURCE    51
#> 2 LAB_WEBSITE    33
#> 3 OTHER         264
#> 4 PROTOCOL       40
#> 5 RAW_DATA      203
external_links |>
    filter(collection_id == collection_id_of_interest)
#> # A tibble: 2 × 4
#>   collection_id                        link_name link_type link_url             
#>   <chr>                                <chr>     <chr>     <chr>                
#> 1 c9706a92-0e5f-46c1-96d8-20e42467f287 <NA>      RAW_DATA  https://data.humance…
#> 2 c9706a92-0e5f-46c1-96d8-20e42467f287 <NA>      RAW_DATA  https://www.ncbi.nlm…
```

Conversely, knowledge of a DOI, etc., can be used to discover details of
the corresponding collection.

``` r
doi_of_interest <- "https://doi.org/10.1016/j.stem.2018.12.011"
links(db) |>
    filter(link_url == doi_of_interest) |>
    left_join(collections(db), by = "collection_id") |>
    glimpse()
#> Rows: 1
#> Columns: 21
#> $ collection_id         <chr> "b1a879f6-5638-48d3-8f64-f6592c1b1561"
#> $ link_name             <chr> "PSC-ATO protocol"
#> $ link_type             <chr> "PROTOCOL"
#> $ link_url              <chr> "https://doi.org/10.1016/j.stem.2018.12.011"
#> $ collection_version_id <chr> "01357a8e-547f-470d-9958-725b38adca04"
#> $ collection_url        <chr> "https://cellxgene.cziscience.com/collections/b1…
#> $ consortia             <list> ["CZI Single-Cell Biology", "Wellcome HCA Strate…
#> $ contact_email         <chr> "st9@sanger.ac.uk"
#> $ contact_name          <chr> "Sarah Teichmann"
#> $ curator_name          <chr> "Batuhan Cakir"
#> $ description           <chr> "Single-cell genomics studies have decoded the i…
#> $ doi                   <chr> "10.1126/science.abo0510"
#> $ links                 <list> [["scVI Models", "DATA_SOURCE", "https://develop…
#> $ name                  <chr> "Mapping the developing human immune system acro…
#> $ publisher_metadata    <list> [[["Suo", "Chenqu"], ["Dann", "Emma"], ["Goh", "…
#> $ revising_in           <lgl> NA
#> $ revision_of           <lgl> NA
#> $ visibility            <chr> "PUBLIC"
#> $ created_at            <date> 2023-08-22
#> $ published_at          <date> 2022-10-04
#> $ revised_at            <date> 2023-08-24
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
selected_files
#> # A tibble: 64 × 4
#>    dataset_id                             filesize filetype url                 
#>    <chr>                                     <dbl> <chr>    <chr>               
#>  1 e47c65a8-7d2f-48b8-908e-04ea6505fa26  800797163 H5AD     https://datasets.ce…
#>  2 e47c65a8-7d2f-48b8-908e-04ea6505fa26  773360314 RDS      https://datasets.ce…
#>  3 c8d40d53-387b-48f2-9f89-72bfdb9c7c9f  385922942 H5AD     https://datasets.ce…
#>  4 c8d40d53-387b-48f2-9f89-72bfdb9c7c9f  362851875 RDS      https://datasets.ce…
#>  5 a6388a6f-6076-401b-9b30-7d4306a20035  315326067 H5AD     https://datasets.ce…
#>  6 a6388a6f-6076-401b-9b30-7d4306a20035  302258458 RDS      https://datasets.ce…
#>  7 a41202e6-173c-477c-8b4d-e0688ee1c4cb   82026236 H5AD     https://datasets.ce…
#>  8 a41202e6-173c-477c-8b4d-e0688ee1c4cb   74894351 RDS      https://datasets.ce…
#>  9 842c6f5d-4a94-4eef-8510-8c792d1124bc 7211362715 H5AD     https://datasets.ce…
#> 10 842c6f5d-4a94-4eef-8510-8c792d1124bc 6817801616 RDS      https://datasets.ce…
#> # ℹ 54 more rows
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
        dataset_id == "de985818-285f-4f59-9dbd-d74968fddba3",
        filetype == "H5AD"
    ) |>
    files_download(dry.run = FALSE)
basename(local_file)
#> [1] "64942e4e-3f6e-4ca0-8226-62e8491b5786.h5ad"
```

These are downloaded to a local cache (use the internal function
`cellxgenedp:::.cellxgenedb_cache_path()` for the location of the
cache), so the process is only time-consuming the first time.

`H5AD` files can be converted to *R* / *Bioconductor* objects using the
[zellkonverter](https://bioconductor.org/packages/zelkonverter) package.

``` r
h5ad <- readH5AD(local_file, use_hdf5 = TRUE, reader = "R")
#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.

#> Warning in H5Aread(A, ...): Reading attribute data of type 'ENUM' not yet
#> implemented. Values replaced by NA's.
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

# API changes

Data access provided by CELLxGENE has changed to a new ‘Discover’
[API](https://api.cellxgene.cziscience.com/curation/ui/). The main
functionality of the
[cellxgenedp](https://bioconductor.org/packages/cellxgenedp) package has
not changed, but specific columns have been removed, replaced or added,
as follows:

`collections()`

- Removed: `access_type`, `data_submission_policy_version`
- Replaced: `updated_at` replaced with `revised_at`
- Added: `collection_version_id`, `collection_url`, `doi`,
  `revising_in`, `revision_of`

`datasets()`

- Removed: `is_valid`, `processing_status`, `published`, `revision`,
  `created_at`
- Replaced: `dataset_deployments` replaced with `explorer_url`, `name`
  replaced with `title`, `updated_at` replaced with `revised_at`
- Added: `dataset_version_id`, `batch_condition`,
  `x_approximate_distribution`

`files()`

- Removed: `file_id`, `filename`, `s3_uri`, `user_submitted`,
  `created_at`, `updated_at`
- Added: `filesize`, `url`

# Session info

    #> R version 4.3.1 (2023-06-16)
    #> Platform: x86_64-pc-linux-gnu (64-bit)
    #> Running under: Ubuntu 22.04.3 LTS
    #> 
    #> Matrix products: default
    #> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    #> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.20.so;  LAPACK version 3.10.0
    #> 
    #> locale:
    #>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    #>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    #>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    #> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    #> 
    #> time zone: UTC
    #> tzcode source: system (glibc)
    #> 
    #> attached base packages:
    #> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    #> [8] base     
    #> 
    #> other attached packages:
    #>  [1] cellxgenedp_1.5.2           dplyr_1.1.2                
    #>  [3] SingleCellExperiment_1.22.0 SummarizedExperiment_1.30.2
    #>  [5] Biobase_2.60.0              GenomicRanges_1.52.0       
    #>  [7] GenomeInfoDb_1.36.1         IRanges_2.34.1             
    #>  [9] S4Vectors_0.38.1            BiocGenerics_0.46.0        
    #> [11] MatrixGenerics_1.12.3       matrixStats_1.0.0          
    #> [13] zellkonverter_1.10.1       
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] dir.expiry_1.8.0        xfun_0.40               htmlwidgets_1.6.2      
    #>  [4] rhdf5_2.44.0            lattice_0.21-8          rhdf5filters_1.12.1    
    #>  [7] vctrs_0.6.3             rjsoncons_1.0.0         tools_4.3.1            
    #> [10] bitops_1.0-7            generics_0.1.3          curl_5.0.2             
    #> [13] parallel_4.3.1          tibble_3.2.1            fansi_1.0.4            
    #> [16] pkgconfig_2.0.3         Matrix_1.5-4.1          lifecycle_1.0.3        
    #> [19] GenomeInfoDbData_1.2.10 compiler_4.3.1          codetools_0.2-19       
    #> [22] httpuv_1.6.11           htmltools_0.5.6         RCurl_1.98-1.12        
    #> [25] yaml_2.3.7              pillar_1.9.0            later_1.3.1            
    #> [28] crayon_1.5.2            ellipsis_0.3.2          DT_0.28                
    #> [31] DelayedArray_0.26.7     abind_1.4-5             mime_0.12              
    #> [34] basilisk_1.12.1         tidyselect_1.2.0        digest_0.6.33          
    #> [37] fastmap_1.1.1           grid_4.3.1              cli_3.6.1              
    #> [40] magrittr_2.0.3          S4Arrays_1.0.5          utf8_1.2.3             
    #> [43] withr_2.5.0             filelock_1.0.2          promises_1.2.1         
    #> [46] rmarkdown_2.24          XVector_0.40.0          httr_1.4.7             
    #> [49] reticulate_1.31         png_0.1-8               HDF5Array_1.28.1       
    #> [52] shiny_1.7.5             evaluate_0.21           knitr_1.43             
    #> [55] basilisk.utils_1.12.1   rlang_1.1.1             Rcpp_1.0.11            
    #> [58] xtable_1.8-4            glue_1.6.2              jsonlite_1.8.7         
    #> [61] Rhdf5lib_1.22.0         R6_2.5.1                zlibbioc_1.46.0
