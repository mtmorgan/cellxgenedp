
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
one or more datasets for download\!

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
#> number of collections(): 103
#> number of datasets(): 538
#> number of files(): 1606
```

The portal organizes data hierarchically, with ‘collections’ (research
studies, approximately), ‘datasets’, and ‘files’. Discover data using
the corresponding functions.

``` r
collections(db)
#> # A tibble: 103 × 16
#>    collec…¹ acces…² conta…³ conta…⁴ curat…⁵ data_…⁶ descr…⁷ genes…⁸ links  name 
#>    <chr>    <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <lgl>   <list> <chr>
#>  1 03f821b… READ    km16@s… Kersti… Batuha… 2.0     It is … NA      <list> Loca…
#>  2 0434a9d… READ    avilla… Alexan… Batuha… 2.0     The va… NA      <list> Acut…
#>  3 3472f32… READ    wongcb… Raymon… Batuha… 2.0     The re… NA      <list> A si…
#>  4 2902f08… READ    lopes@… S. M. … Wei Kh… 2.0     The ov… NA      <list> Sing…
#>  5 83ed3be… READ    tom.ta… Tom Ta… Jennif… 2.0     During… NA      <list> Inte…
#>  6 2b02dff… READ    miriam… Miriam… Batuha… 2.0     Clinic… NA      <list> Sing…
#>  7 eb735cc… READ    rv4@sa… Roser … Batuha… 2.0     Human … NA      <list> Samp…
#>  8 44531dd… READ    tallul… Tallul… Jennif… 2.0     The cr… NA      <list> Sing…
#>  9 e75342a… READ    nhuebn… Norber… Jennif… 2.0     Pathog… NA      <list> Path…
#> 10 125eef5… READ    my4@sa… Matthe… Jason … 2.0     Unders… NA      <list> Sing…
#> # … with 93 more rows, 6 more variables: publisher_metadata <list>,
#> #   visibility <chr>, created_at <date>, published_at <date>,
#> #   revised_at <date>, updated_at <date>, and abbreviated variable names
#> #   ¹​collection_id, ²​access_type, ³​contact_email, ⁴​contact_name, ⁵​curator_name,
#> #   ⁶​data_submission_policy_version, ⁷​description, ⁸​genesets

datasets(db)
#> # A tibble: 538 × 28
#>    dataset_id     colle…¹ donor…² assay  cell_…³ cell_…⁴ datas…⁵ devel…⁶ disease
#>    <chr>          <chr>   <list>  <list>   <int> <list>  <chr>   <list>  <list> 
#>  1 edc8d3fe-153c… 03f821… <list>  <list>  236977 <list>  https:… <list>  <list> 
#>  2 2a498ace-872a… 03f821… <list>  <list>  422220 <list>  https:… <list>  <list> 
#>  3 fa8605cf-f27e… 0434a9… <list>  <list>   59506 <list>  https:… <list>  <list> 
#>  4 d5c67a4e-a8d9… 3472f3… <list>  <list>   19694 <list>  https:… <list>  <list> 
#>  5 1f1c5c14-5949… 2902f0… <list>  <list>   20676 <list>  https:… <list>  <list> 
#>  6 11ff73e8-d3e4… 83ed3b… <list>  <list>   71732 <list>  https:… <list>  <list> 
#>  7 36c867a7-be10… 2b02df… <list>  <list>   32458 <list>  https:… <list>  <list> 
#>  8 c2a461b1-0c15… eb735c… <list>  <list>   97499 <list>  https:… <list>  <list> 
#>  9 0895c838-e550… 44531d… <list>  <list>     146 <list>  https:… <list>  <list> 
#> 10 a49d9109-1d0c… 44531d… <list>  <list>    2346 <list>  https:… <list>  <list> 
#> # … with 528 more rows, 19 more variables: is_primary_data <chr>,
#> #   is_valid <lgl>, linked_genesets <lgl>, mean_genes_per_cell <dbl>,
#> #   name <chr>, organism <list>, processing_status <list>, published <lgl>,
#> #   revision <int>, schema_version <chr>, self_reported_ethnicity <list>,
#> #   sex <list>, suspension_type <list>, tissue <list>, tombstone <lgl>,
#> #   created_at <date>, published_at <date>, revised_at <date>,
#> #   updated_at <date>, and abbreviated variable names ¹​collection_id, …

files(db)
#> # A tibble: 1,606 × 8
#>    file_id          datas…¹ filen…² filet…³ s3_uri user_…⁴ created_at updated_at
#>    <chr>            <chr>   <chr>   <chr>   <chr>  <lgl>   <date>     <date>    
#>  1 8c4737ab-cd8d-4… edc8d3… explor… CXG     s3://… TRUE    2022-10-18 2022-10-18
#>  2 15fda108-90fd-4… edc8d3… local.… RDS     s3://… TRUE    2022-10-18 2022-10-18
#>  3 4a052f7b-7de0-4… edc8d3… local.… H5AD    s3://… TRUE    2022-10-18 2022-10-18
#>  4 e6fd765c-bcfe-4… 2a498a… local.… H5AD    s3://… TRUE    2022-10-18 2022-10-18
#>  5 9a8737f1-775f-4… 2a498a… explor… CXG     s3://… TRUE    2022-10-18 2022-10-18
#>  6 aeb40efc-77ae-4… 2a498a… local.… RDS     s3://… TRUE    2022-10-18 2022-10-18
#>  7 b50c48f1-ef5e-4… fa8605… local.… H5AD    s3://… TRUE    2022-10-20 2022-10-20
#>  8 59309f21-0db8-4… fa8605… local.… RDS     s3://… TRUE    2022-10-20 2022-10-20
#>  9 399c2655-f56a-4… fa8605… explor… CXG     s3://… TRUE    2022-10-20 2022-10-20
#> 10 1027b8d1-6b71-4… d5c67a… local.… RDS     s3://… TRUE    2022-10-17 2022-10-18
#> # … with 1,596 more rows, and abbreviated variable names ¹​dataset_id,
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
#> Columns: 16
#> $ collection_id                  <chr> "8e880741-bf9a-4c8e-9227-934204631d2a"
#> $ access_type                    <chr> "READ"
#> $ contact_email                  <chr> "jmarshal@broadinstitute.org"
#> $ contact_name                   <chr> "Jamie L Marshall"
#> $ curator_name                   <chr> "Jennifer Yu-Sheng Chien"
#> $ data_submission_policy_version <chr> "2.0"
#> $ description                    <chr> "High resolution spatial transcriptomic…
#> $ genesets                       <lgl> NA
#> $ links                          <list> [["", "RAW_DATA", "https://www.ncbi.nlm…
#> $ name                           <chr> "High Resolution Slide-seqV2 Spatial Tr…
#> $ publisher_metadata             <list> [[["Marshall", "Jamie L."], ["Noel", "T…
#> $ visibility                     <chr> "PUBLIC"
#> $ created_at                     <date> 2021-05-28
#> $ published_at                   <date> 2021-12-09
#> $ revised_at                     <date> 2022-10-24
#> $ updated_at                     <date> 2022-10-24
```

We can take a similar strategy to identify all datasets belonging to
this collection

``` r
left_join(
    collection_with_most_datasets |> select(collection_id),
    datasets(db),
    by = "collection_id"
)
#> # A tibble: 129 × 28
#>    collection_id  datas…¹ donor…² assay  cell_…³ cell_…⁴ datas…⁵ devel…⁶ disease
#>    <chr>          <chr>   <list>  <list>   <int> <list>  <chr>   <list>  <list> 
#>  1 8e880741-bf9a… ff77ee… <list>  <list>   38024 <list>  https:… <list>  <list> 
#>  2 8e880741-bf9a… 5c451b… <list>  <list>   13147 <list>  https:… <list>  <list> 
#>  3 8e880741-bf9a… 4ebe33… <list>  <list>   17909 <list>  https:… <list>  <list> 
#>  4 8e880741-bf9a… 88b7da… <list>  <list>   44588 <list>  https:… <list>  <list> 
#>  5 8e880741-bf9a… 230eee… <list>  <list>   22430 <list>  https:… <list>  <list> 
#>  6 8e880741-bf9a… 1831d8… <list>  <list>   22458 <list>  https:… <list>  <list> 
#>  7 8e880741-bf9a… 868026… <list>  <list>   31194 <list>  https:… <list>  <list> 
#>  8 8e880741-bf9a… b62755… <list>  <list>   22502 <list>  https:… <list>  <list> 
#>  9 8e880741-bf9a… 348383… <list>  <list>   27814 <list>  https:… <list>  <list> 
#> 10 8e880741-bf9a… 4f420b… <list>  <list>   19886 <list>  https:… <list>  <list> 
#> # … with 119 more rows, 19 more variables: is_primary_data <chr>,
#> #   is_valid <lgl>, linked_genesets <lgl>, mean_genes_per_cell <dbl>,
#> #   name <chr>, organism <list>, processing_status <list>, published <lgl>,
#> #   revision <int>, schema_version <chr>, self_reported_ethnicity <list>,
#> #   sex <list>, suspension_type <list>, tissue <list>, tombstone <lgl>,
#> #   created_at <date>, published_at <date>, revised_at <date>,
#> #   updated_at <date>, and abbreviated variable names ¹​dataset_id, ²​donor_id, …
```

## `facets()` provides information on ‘levels’ present in specific columns

Notice that some columns are ‘lists’ rather than atomic vectors like
‘character’ or ‘integer’.

``` r
datasets(db) |>
    select(where(is.list))
#> # A tibble: 538 × 11
#>    donor_id   assay  cell_…¹ devel…² disease organ…³ processing…⁴ self_…⁵ sex   
#>    <list>     <list> <list>  <list>  <list>  <list>  <list>       <list>  <list>
#>  1 <list>     <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  2 <list>     <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  3 <list>     <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  4 <list [3]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  5 <list [5]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  6 <list [5]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  7 <list>     <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  8 <list>     <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#>  9 <list [4]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#> 10 <list [4]> <list> <list>  <list>  <list>  <list>  <named list> <list>  <list>
#> # … with 528 more rows, 2 more variables: suspension_type <list>,
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
#>  1 assay 10x 3' v3                      EFO:0009922        188
#>  2 assay 10x 3' v2                      EFO:0009899        162
#>  3 assay Slide-seqV2                    EFO:0030062        129
#>  4 assay 10x 5' v1                      EFO:0011025         43
#>  5 assay Smart-seq2                     EFO:0008931         36
#>  6 assay Visium Spatial Gene Expression EFO:0010961         35
#>  7 assay 10x multiome                   EFO:0030059         24
#>  8 assay Drop-seq                       EFO:0008722         11
#>  9 assay 10x 3' transcription profiling EFO:0030003          9
#> 10 assay 10x 5' v2                      EFO:0009900          9
#> # … with 22 more rows
facets(db, "self_reported_ethnicity")
#> # A tibble: 18 × 4
#>    facet                   label                                   ontol…¹     n
#>    <chr>                   <chr>                                   <chr>   <int>
#>  1 self_reported_ethnicity unknown                                 unknown   210
#>  2 self_reported_ethnicity European                                HANCES…   181
#>  3 self_reported_ethnicity na                                      na        175
#>  4 self_reported_ethnicity Asian                                   HANCES…    59
#>  5 self_reported_ethnicity African American                        HANCES…    37
#>  6 self_reported_ethnicity multiethnic                             multie…    24
#>  7 self_reported_ethnicity Greater Middle Eastern  (Middle Easter… HANCES…    21
#>  8 self_reported_ethnicity Hispanic or Latin American              HANCES…    16
#>  9 self_reported_ethnicity African American or Afro-Caribbean      HANCES…     5
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
#> 1 sex   male    PATO:0000384       456
#> 2 sex   female  PATO:0000383       315
#> 3 sex   unknown unknown             48
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
#> 1          2608650
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
#> # A tibble: 7 × 16
#>   collect…¹ acces…² conta…³ conta…⁴ curat…⁵ data_…⁶ descr…⁷ genes…⁸ links  name 
#>   <chr>     <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <lgl>   <list> <chr>
#> 1 c9706a92… READ    hnaksh… Harikr… Jennif… 2.0     "Singl… NA      <list> A si…
#> 2 2f75d249… READ    rsatij… Rahul … Jennif… 2.0     "This … NA      <list> Azim…
#> 3 b9fc3d70… READ    bruce.… Bruce … Jennif… 2.0     "Numer… NA      <list> A We…
#> 4 62e8f058… READ    chanj3… Joseph… Jennif… 2.0     "155,0… NA      <list> HTAN…
#> 5 625f6bf4… READ    a5wang… Allen … Jennif… 2.0     "Large… NA      <list> Lung…
#> 6 b953c942… READ    icobos… Inma C… Jennif… 2.0     "Tau a… NA      <list> Sing…
#> 7 bcb61471… READ    info@k… KPMP    Jennif… 2.0     "Under… NA      <list> An a…
#> # … with 6 more variables: publisher_metadata <list>, visibility <chr>,
#> #   created_at <date>, published_at <date>, revised_at <date>,
#> #   updated_at <date>, and abbreviated variable names ¹​collection_id,
#> #   ²​access_type, ³​contact_email, ⁴​contact_name, ⁵​curator_name,
#> #   ⁶​data_submission_policy_version, ⁷​description, ⁸​genesets
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
#> # A tibble: 63 × 8
#>    dataset_id       file_id filen…¹ filet…² s3_uri user_…³ created_at updated_at
#>    <chr>            <chr>   <chr>   <chr>   <chr>  <lgl>   <date>     <date>    
#>  1 de985818-285f-4… 15e9d9… local.… H5AD    s3://… TRUE    2022-10-21 2022-10-21
#>  2 de985818-285f-4… 0d3974… explor… CXG     s3://… TRUE    2022-10-21 2022-10-21
#>  3 de985818-285f-4… e254f9… local.… RDS     s3://… TRUE    2022-10-21 2022-10-21
#>  4 f72958f5-7f42-4… 59bd46… local.… RDS     s3://… TRUE    2022-10-18 2022-10-18
#>  5 f72958f5-7f42-4… 3a2467… explor… CXG     s3://… TRUE    2022-10-18 2022-10-18
#>  6 f72958f5-7f42-4… d9f9d0… local.… H5AD    s3://… TRUE    2022-10-18 2022-10-18
#>  7 bc2a7b3d-f04e-4… f6d9f2… local.… H5AD    s3://… TRUE    2022-10-18 2022-10-18
#>  8 bc2a7b3d-f04e-4… 46de9c… explor… CXG     s3://… TRUE    2022-10-18 2022-10-18
#>  9 bc2a7b3d-f04e-4… 5331f2… local.… RDS     s3://… TRUE    2022-10-18 2022-10-18
#> 10 96a3f64b-0ee9-4… b77452… local.… H5AD    s3://… TRUE    2022-10-18 2022-10-18
#> # … with 53 more rows, and abbreviated variable names ¹​filename, ²​filetype,
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
        dataset_id == "3de0ad6d-4378-4f62-b37b-ec0b75a50d94",
        filetype == "H5AD"
    ) |>
    files_download(dry.run = FALSE)
basename(local_file)
#> [1] "f69ba4b3-fc45-483c-8a7c-434fd056aeed.H5AD"
```

These are downloaded to a local cache (use the internal function
`cellxgenedp:::.cellxgenedb_cache_path()` for the location of the
cache), so the process is only time-consuming the first time.

`H5AD` files can be converted to *R* / *Bioconductor* objects using the
[zellkonverter](https://bioconductor.org/packages/zelkonverter) package.

``` r
h5ad <- readH5AD(local_file, use_hdf5 = TRUE)
#> + '/home/runner/.cache/R/basilisk/1.9.11/0/bin/conda' 'create' '--yes' '--prefix' '/home/runner/.cache/R/basilisk/1.9.11/zellkonverter/1.7.7/zellkonverterAnnDataEnv-0.8.0' 'python=3.8.13' '--quiet' '-c' 'conda-forge'
#> + '/home/runner/.cache/R/basilisk/1.9.11/0/bin/conda' 'install' '--yes' '--prefix' '/home/runner/.cache/R/basilisk/1.9.11/zellkonverter/1.7.7/zellkonverterAnnDataEnv-0.8.0' 'python=3.8.13'
#> + '/home/runner/.cache/R/basilisk/1.9.11/0/bin/conda' 'install' '--yes' '--prefix' '/home/runner/.cache/R/basilisk/1.9.11/zellkonverter/1.7.7/zellkonverterAnnDataEnv-0.8.0' '-c' 'conda-forge' 'python=3.8.13' 'anndata=0.8.0' 'h5py=3.6.0' 'hdf5=1.12.1' 'natsort=8.1.0' 'numpy=1.22.3' 'packaging=21.3' 'pandas=1.4.2' 'python=3.8.13' 'scipy=1.7.3' 'sqlite=3.38.2'
h5ad
#> class: SingleCellExperiment 
#> dim: 26329 46500 
#> metadata(3): cell_type_ontology_term_id_colors schema_version title
#> assays(1): X
#> rownames(26329): ENSG00000182308 ENSG00000124827 ... ENSG00000155229
#>   ENSG00000105609
#> rowData names(4): feature_is_filtered feature_name feature_reference
#>   feature_biotype
#> colnames(46500): D032_AACAAGACAGCCCACA D032_AACAGGGGTCCAGCGT ...
#>   D231_CGAGTGCTCAACCCGG D231_TTCGCTGAGGAACATT
#> colData names(26): nCount_RNA nFeature_RNA ... self_reported_ethnicity
#>   development_stage
#> reducedDimNames(1): X_umap
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
#> # A tibble: 9 × 3
#>   sex    donor_id     n
#>   <fct>  <fct>    <int>
#> 1 female D088      5903
#> 2 female D139      5217
#> 3 female D175      1778
#> 4 female D231      4680
#> 5 male   D032      4970
#> 6 male   D046      8894
#> 7 male   D062      4852
#> 8 male   D122      3935
#> 9 male   D150      6271
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

    #> R version 4.2.1 (2022-06-23)
    #> Platform: x86_64-pc-linux-gnu (64-bit)
    #> Running under: Ubuntu 20.04.5 LTS
    #> 
    #> Matrix products: default
    #> BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0
    #> LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0
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
    #>  [1] cellxgenedp_1.1.7           dplyr_1.0.10               
    #>  [3] SingleCellExperiment_1.19.1 SummarizedExperiment_1.27.3
    #>  [5] Biobase_2.57.1              GenomicRanges_1.49.1       
    #>  [7] GenomeInfoDb_1.33.15        IRanges_2.31.2             
    #>  [9] S4Vectors_0.35.4            BiocGenerics_0.43.4        
    #> [11] MatrixGenerics_1.9.1        matrixStats_0.62.0         
    #> [13] zellkonverter_1.7.7        
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] Rcpp_1.0.9             here_1.0.1             dir.expiry_1.5.1      
    #>  [4] lattice_0.20-45        png_0.1-7              rprojroot_2.0.3       
    #>  [7] digest_0.6.30          utf8_1.2.2             mime_0.12             
    #> [10] R6_2.5.1               evaluate_0.17          httr_1.4.4            
    #> [13] pillar_1.8.1           basilisk_1.9.11        zlibbioc_1.43.0       
    #> [16] rlang_1.0.6            curl_4.3.3             Matrix_1.5-1          
    #> [19] DT_0.26                reticulate_1.26        rmarkdown_2.17        
    #> [22] stringr_1.4.1          htmlwidgets_1.5.4      RCurl_1.98-1.9        
    #> [25] HDF5Array_1.25.2       shiny_1.7.2            DelayedArray_0.23.2   
    #> [28] compiler_4.2.1         httpuv_1.6.6           xfun_0.34             
    #> [31] pkgconfig_2.0.3        htmltools_0.5.3        tidyselect_1.2.0      
    #> [34] tibble_3.1.8           GenomeInfoDbData_1.2.9 codetools_0.2-18      
    #> [37] fansi_1.0.3            withr_2.5.0            later_1.3.0           
    #> [40] rhdf5filters_1.9.0     bitops_1.0-7           rjsoncons_1.0.0       
    #> [43] basilisk.utils_1.9.4   grid_4.2.1             xtable_1.8-4          
    #> [46] jsonlite_1.8.3         lifecycle_1.0.3        magrittr_2.0.3        
    #> [49] cli_3.4.1              stringi_1.7.8          XVector_0.37.1        
    #> [52] renv_0.16.0            promises_1.2.0.1       ellipsis_0.3.2        
    #> [55] filelock_1.0.2         generics_0.1.3         vctrs_0.5.0           
    #> [58] Rhdf5lib_1.19.2        tools_4.2.1            glue_1.6.2            
    #> [61] parallel_4.2.1         fastmap_1.1.0          yaml_2.3.6            
    #> [64] rhdf5_2.41.1           knitr_1.40
