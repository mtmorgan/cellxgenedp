
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
#> number of collections(): 101
#> number of datasets(): 530
#> number of files(): 1582
```

The portal organizes data hierarchically, with ‘collections’ (research
studies, approximately), ‘datasets’, and ‘files’. Discover data using
the corresponding functions.

``` r
collections(db)
#> # A tibble: 101 × 16
#>    collec…¹ acces…² conta…³ conta…⁴ curat…⁵ data_…⁶ descr…⁷ genes…⁸ links  name 
#>    <chr>    <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <lgl>   <list> <chr>
#>  1 03f821b… READ    km16@s… Kersti… Batuha… 2.0     It is … NA      <list> Loca…
#>  2 6e8c541… READ    a.vano… Alexan… Jennif… 2.0     A Sing… NA      <list> Mura…
#>  3 3472f32… READ    wongcb… Raymon… Batuha… 2.0     The re… NA      <list> A si…
#>  4 83ed3be… READ    tom.ta… Tom Ta… Jennif… 2.0     During… NA      <list> Inte…
#>  5 92fde06… READ    c.nove… Claudi… Jason … 2.0     The ce… NA      <list> A co…
#>  6 eb735cc… READ    rv4@sa… Roser … Batuha… 2.0     Human … NA      <list> Samp…
#>  7 e75342a… READ    nhuebn… Norber… Jennif… 2.0     Pathog… NA      <list> Path…
#>  8 125eef5… READ    my4@sa… Matthe… Jason … 2.0     Unders… NA      <list> Sing…
#>  9 c9706a9… READ    hnaksh… Harikr… Jennif… 2.0     Single… NA      <list> A si…
#> 10 5d44596… READ    angela… Angela… Jennif… 2.0     Drople… NA      <list> A mo…
#> # … with 91 more rows, 6 more variables: publisher_metadata <list>,
#> #   visibility <chr>, created_at <date>, published_at <date>,
#> #   revised_at <date>, updated_at <date>, and abbreviated variable names
#> #   ¹​collection_id, ²​access_type, ³​contact_email, ⁴​contact_name, ⁵​curator_name,
#> #   ⁶​data_submission_policy_version, ⁷​description, ⁸​genesets

datasets(db)
#> # A tibble: 530 × 26
#>    dataset_id     colle…¹ assay  cell_…² cell_…³ datas…⁴ devel…⁵ disease is_pr…⁶
#>    <chr>          <chr>   <list>   <int> <list>  <chr>   <list>  <list>  <chr>  
#>  1 edc8d3fe-153c… 03f821… <list>  236977 <list>  https:… <list>  <list>  PRIMARY
#>  2 2a498ace-872a… 03f821… <list>  422220 <list>  https:… <list>  <list>  PRIMARY
#>  3 b07e5164-baf6… 6e8c54… <list>    2126 <list>  https:… <list>  <list>  PRIMARY
#>  4 d5c67a4e-a8d9… 3472f3… <list>   19694 <list>  https:… <list>  <list>  PRIMARY
#>  5 11ff73e8-d3e4… 83ed3b… <list>   71732 <list>  https:… <list>  <list>  PRIMARY
#>  6 42bb7f78-cef8… 92fde0… <list>  141401 <list>  https:… <list>  <list>  PRIMARY
#>  7 c2a461b1-0c15… eb735c… <list>   97499 <list>  https:… <list>  <list>  PRIMARY
#>  8 9434b020-de42… e75342… <list>   59217 <list>  https:… <list>  <list>  SECOND…
#>  9 bdf69f8d-5a96… e75342… <list>    2576 <list>  https:… <list>  <list>  SECOND…
#> 10 83b5e943-a1d5… e75342… <list>    7999 <list>  https:… <list>  <list>  SECOND…
#> # … with 520 more rows, 17 more variables: is_valid <lgl>,
#> #   linked_genesets <lgl>, mean_genes_per_cell <dbl>, name <chr>,
#> #   organism <list>, processing_status <list>, published <lgl>, revision <int>,
#> #   schema_version <chr>, self_reported_ethnicity <list>, sex <list>,
#> #   tissue <list>, tombstone <lgl>, created_at <date>, published_at <date>,
#> #   revised_at <date>, updated_at <date>, and abbreviated variable names
#> #   ¹​collection_id, ²​cell_count, ³​cell_type, ⁴​dataset_deployments, …

files(db)
#> # A tibble: 1,582 × 8
#>    file_id          datas…¹ filen…² filet…³ s3_uri user_…⁴ created_at updated_at
#>    <chr>            <chr>   <chr>   <chr>   <chr>  <lgl>   <date>     <date>    
#>  1 1e788c65-3422-4… edc8d3… local.… H5AD    s3://… TRUE    2022-08-22 2022-08-23
#>  2 24d08b4a-7314-4… edc8d3… local.… RDS     s3://… TRUE    2022-08-22 2022-08-23
#>  3 88e0bdc6-8d3c-4… edc8d3… explor… CXG     s3://… TRUE    2022-08-22 2022-08-23
#>  4 f93c1a77-ab7a-4… 2a498a… local.… H5AD    s3://… TRUE    2022-08-22 2022-08-23
#>  5 d17fddad-4907-4… 2a498a… local.… RDS     s3://… TRUE    2022-08-22 2022-08-23
#>  6 f68fa37e-fb6f-4… 2a498a… explor… CXG     s3://… TRUE    2022-08-22 2022-08-23
#>  7 fce7ca81-6d88-4… b07e51… local.… H5AD    s3://… TRUE    2022-08-24 2022-08-29
#>  8 1da81a7b-ce64-4… b07e51… explor… CXG     s3://… TRUE    2022-08-24 2022-08-29
#>  9 dc9806d3-a959-4… b07e51… local.… RDS     s3://… TRUE    2022-08-24 2022-08-29
#> 10 0d143085-cf3f-4… d5c67a… local.… H5AD    s3://… TRUE    2022-08-16 2022-08-16
#> # … with 1,572 more rows, and abbreviated variable names ¹​dataset_id,
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
#> $ links                          <list> [["Macosko Lab Slide-seq Github", "OTHE…
#> $ name                           <chr> "High Resolution Slide-seqV2 Spatial Tr…
#> $ publisher_metadata             <list> [[["Marshall", "Jamie L."], ["Noel", "T…
#> $ visibility                     <chr> "PUBLIC"
#> $ created_at                     <date> 2021-05-28
#> $ published_at                   <date> 2021-12-09
#> $ revised_at                     <date> 2022-10-06
#> $ updated_at                     <date> 2022-10-06
```

We can take a similar strategy to identify all datasets belonging to
this collection

``` r
left_join(
    collection_with_most_datasets |> select(collection_id),
    datasets(db),
    by = "collection_id"
)
#> # A tibble: 129 × 26
#>    collection_id  datas…¹ assay  cell_…² cell_…³ datas…⁴ devel…⁵ disease is_pr…⁶
#>    <chr>          <chr>   <list>   <int> <list>  <chr>   <list>  <list>  <chr>  
#>  1 8e880741-bf9a… c5ac9b… <list>   21181 <list>  https:… <list>  <list>  PRIMARY
#>  2 8e880741-bf9a… 4ebe33… <list>   17909 <list>  https:… <list>  <list>  PRIMARY
#>  3 8e880741-bf9a… a5ecb4… <list>   19029 <list>  https:… <list>  <list>  PRIMARY
#>  4 8e880741-bf9a… 88b7da… <list>   44588 <list>  https:… <list>  <list>  PRIMARY
#>  5 8e880741-bf9a… 5c451b… <list>   13147 <list>  https:… <list>  <list>  PRIMARY
#>  6 8e880741-bf9a… b8bd55… <list>   34355 <list>  https:… <list>  <list>  PRIMARY
#>  7 8e880741-bf9a… 3679ae… <list>   10701 <list>  https:… <list>  <list>  PRIMARY
#>  8 8e880741-bf9a… b62755… <list>   22502 <list>  https:… <list>  <list>  PRIMARY
#>  9 8e880741-bf9a… ff77ee… <list>   38024 <list>  https:… <list>  <list>  PRIMARY
#> 10 8e880741-bf9a… d4f003… <list>   27429 <list>  https:… <list>  <list>  PRIMARY
#> # … with 119 more rows, 17 more variables: is_valid <lgl>,
#> #   linked_genesets <lgl>, mean_genes_per_cell <dbl>, name <chr>,
#> #   organism <list>, processing_status <list>, published <lgl>, revision <int>,
#> #   schema_version <chr>, self_reported_ethnicity <list>, sex <list>,
#> #   tissue <list>, tombstone <lgl>, created_at <date>, published_at <date>,
#> #   revised_at <date>, updated_at <date>, and abbreviated variable names
#> #   ¹​dataset_id, ²​cell_count, ³​cell_type, ⁴​dataset_deployments, …
```

## `facets()` provides information on ‘levels’ present in specific columns

Notice that some columns are ‘lists’ rather than atomic vectors like
‘character’ or ‘integer’.

``` r
datasets(db) |>
    select(where(is.list))
#> # A tibble: 530 × 9
#>    assay      cell_…¹ devel…² disease organ…³ processing…⁴ self_…⁵ sex    tissue
#>    <list>     <list>  <list>  <list>  <list>  <list>       <list>  <list> <list>
#>  1 <list [2]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#>  2 <list [1]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#>  3 <list [1]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#>  4 <list [1]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#>  5 <list [1]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#>  6 <list [5]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#>  7 <list [1]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#>  8 <list [2]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#>  9 <list [2]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#> 10 <list [2]> <list>  <list>  <list>  <list>  <named list> <list>  <list> <list>
#> # … with 520 more rows, and abbreviated variable names ¹​cell_type,
#> #   ²​development_stage, ³​organism, ⁴​processing_status, ⁵​self_reported_ethnicity
```

This indicates that at least some of the datasets had more than one type
of `assay`, `cell_type`, etc. The `facets()` function provides a
convenient way of discovering possible levels of each column, e.g.,
`assay`, `organism`, `self_reported_ethnicity`, or `sex`, and the number
of datasets with each label.

``` r
facets(db, "assay")
#> # A tibble: 30 × 4
#>    facet label                          ontology_term_id     n
#>    <chr> <chr>                          <chr>            <int>
#>  1 assay 10x 3' v3                      EFO:0009922        180
#>  2 assay 10x 3' v2                      EFO:0009899        162
#>  3 assay Slide-seq                      EFO:0009920        129
#>  4 assay 10x 5' v1                      EFO:0011025         43
#>  5 assay Smart-seq2                     EFO:0008931         36
#>  6 assay Visium Spatial Gene Expression EFO:0010961         35
#>  7 assay 10x technology                 EFO:0008995         30
#>  8 assay Drop-seq                       EFO:0008722         11
#>  9 assay 10x 3' transcription profiling EFO:0030003          9
#> 10 assay 10x 5' v2                      EFO:0009900          9
#> # … with 20 more rows
facets(db, "self_reported_ethnicity")
#> # A tibble: 18 × 4
#>    facet                   label                                   ontol…¹     n
#>    <chr>                   <chr>                                   <chr>   <int>
#>  1 self_reported_ethnicity unknown                                 unknown   209
#>  2 self_reported_ethnicity European                                HANCES…   181
#>  3 self_reported_ethnicity na                                      na        168
#>  4 self_reported_ethnicity Asian                                   HANCES…    59
#>  5 self_reported_ethnicity African American                        HANCES…    37
#>  6 self_reported_ethnicity admixed ancestry                        HANCES…    24
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
#> 1 sex   male    PATO:0000384       451
#> 2 sex   female  PATO:0000383       308
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
#> 3 62e8f058… READ    chanj3… Joseph… Jennif… 2.0     "155,0… NA      <list> HTAN…
#> 4 bcb61471… READ    info@k… KPMP    Jennif… 2.0     "Under… NA      <list> An a…
#> 5 b9fc3d70… READ    bruce.… Bruce … Jennif… 2.0     "Numer… NA      <list> A We…
#> 6 625f6bf4… READ    a5wang… Allen … Jennif… 2.0     "Large… NA      <list> Lung…
#> 7 b953c942… READ    icobos… Inma C… Jennif… 2.0     "Tau a… NA      <list> Sing…
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
#>  1 de985818-285f-4… d5c6de… local.… H5AD    s3://… TRUE    2021-09-24 2021-09-24
#>  2 de985818-285f-4… a0bcae… local.… RDS     s3://… TRUE    2021-09-24 2021-12-21
#>  3 de985818-285f-4… dff842… explor… CXG     s3://… TRUE    2021-09-24 2021-09-24
#>  4 f72958f5-7f42-4… a13168… local.… H5AD    s3://… TRUE    2022-08-30 2022-08-30
#>  5 f72958f5-7f42-4… 155b79… explor… CXG     s3://… TRUE    2022-08-30 2022-08-30
#>  6 f72958f5-7f42-4… 2f85a7… local.… RDS     s3://… TRUE    2022-08-30 2022-08-30
#>  7 d224c8e0-c28e-4… 44ac7f… explor… CXG     s3://… TRUE    2022-09-27 2022-09-30
#>  8 d224c8e0-c28e-4… f73413… local.… RDS     s3://… TRUE    2022-09-27 2022-09-30
#>  9 d224c8e0-c28e-4… 22fbf4… local.… H5AD    s3://… TRUE    2022-09-27 2022-09-30
#> 10 d4cfefa0-3a35-4… fc43a9… local.… H5AD    s3://… TRUE    2022-09-27 2022-09-30
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
#> [1] "f4065ffa-c2d6-45bf-b596-5a69e36d8fcd.H5AD"
```

These are downloaded to a local cache (use the internal function
`cellxgenedp:::.cellxgenedb_cache_path()` for the location of the
cache), so the process is only time-consuming the first time.

`H5AD` files can be converted to *R* / *Bioconductor* objects using the
[zellkonverter](https://bioconductor.org/packages/zelkonverter) package.

``` r
h5ad <- readH5AD(local_file, reader = "R", use_hdf5 = TRUE)
h5ad
#> class: SingleCellExperiment 
#> dim: 26329 46500 
#> metadata(5): X_normalization cell_type_ontology_term_id_colors
#>   layer_descriptions schema_version title
#> assays(1): X
#> rownames: NULL
#> rowData names(5): feature_biotype feature_id feature_is_filtered
#>   feature_name feature_reference
#> colnames(46500): D032_AACAAGACAGCCCACA D032_AACAGGGGTCCAGCGT ...
#>   D231_CGAGTGCTCAACCCGG D231_TTCGCTGAGGAACATT
#> colData names(25): assay assay_ontology_term_id ... tissue
#>   tissue_ontology_term_id
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
    #>  [1] cellxgenedp_1.1.6           dplyr_1.0.10               
    #>  [3] SingleCellExperiment_1.19.1 SummarizedExperiment_1.27.3
    #>  [5] Biobase_2.57.1              GenomicRanges_1.49.1       
    #>  [7] GenomeInfoDb_1.33.8         IRanges_2.31.2             
    #>  [9] S4Vectors_0.35.4            BiocGenerics_0.43.4        
    #> [11] MatrixGenerics_1.9.1        matrixStats_0.62.0         
    #> [13] zellkonverter_1.7.7        
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] Rcpp_1.0.9             dir.expiry_1.5.1       lattice_0.20-45       
    #>  [4] png_0.1-7              digest_0.6.29          utf8_1.2.2            
    #>  [7] mime_0.12              R6_2.5.1               evaluate_0.17         
    #> [10] httr_1.4.4             pillar_1.8.1           basilisk_1.9.11       
    #> [13] zlibbioc_1.43.0        rlang_1.0.6            curl_4.3.3            
    #> [16] Matrix_1.5-1           DT_0.25                reticulate_1.26       
    #> [19] rmarkdown_2.17         stringr_1.4.1          htmlwidgets_1.5.4     
    #> [22] RCurl_1.98-1.9         HDF5Array_1.25.2       shiny_1.7.2           
    #> [25] DelayedArray_0.23.2    compiler_4.2.1         httpuv_1.6.6          
    #> [28] xfun_0.33              pkgconfig_2.0.3        htmltools_0.5.3       
    #> [31] tidyselect_1.2.0       tibble_3.1.8           GenomeInfoDbData_1.2.9
    #> [34] codetools_0.2-18       fansi_1.0.3            withr_2.5.0           
    #> [37] later_1.3.0            rhdf5filters_1.9.0     bitops_1.0-7          
    #> [40] rjsoncons_1.0.0        basilisk.utils_1.9.4   grid_4.2.1            
    #> [43] xtable_1.8-4           jsonlite_1.8.2         lifecycle_1.0.3       
    #> [46] magrittr_2.0.3         cli_3.4.1              stringi_1.7.8         
    #> [49] XVector_0.37.1         renv_0.16.0            promises_1.2.0.1      
    #> [52] ellipsis_0.3.2         filelock_1.0.2         generics_0.1.3        
    #> [55] vctrs_0.4.2            Rhdf5lib_1.19.2        tools_4.2.1           
    #> [58] glue_1.6.2             parallel_4.2.1         fastmap_1.1.0         
    #> [61] yaml_2.3.5             rhdf5_2.41.1           knitr_1.40
