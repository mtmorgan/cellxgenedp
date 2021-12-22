# Installation and use

This package is not yet available on *Bioconductor*. Install from GitHub
using the following commands

``` r
installed_packages <- rownames(installed.packages())

## packages required for installation
pkgs <- c("remotes", "BiocManager")
required_pkgs <- pkgs[!pkgs %in% installed_packages]
install.packages(required_pkgs, repos = "https://cloud.r-project.org")

## the cellxgenedp package and dependencies
vignette_dependencies <- c("zellkonverter", "SingleCellExperiment", "tidyr")
required_pkgs <-
    vignette_dependencies[!vignette_dependencies %in% installed_packages]
BiocManager::install(c(required_pkgs, "mtmorgan/cellxgenedp"))
```

Load the package into your current *R* session. We make extensive use of
the dplyr and tidyr packages, and at the end of the vignette use
SingleCellExperiment and zellkonverter, so load those as well.

``` r
suppressPackageStartupMessages({
    library(zellkonverter)
    library(SingleCellExperiment) # load early to avoid masking dplyr::count()
    library(dplyr)
    library(tidyr)
    library(cellxgenedp)
})
```

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
```

    ## cellxgene_db
    ## number of collections(): 48
    ## number of datasets(): 223
    ## number of files(): 667

The portal organizes data hierarchically, with ‘collections’ (research
studies, approximately), ‘datasets’, and ‘files’. Discover data using
the corresponding functions.

``` r
collections(db)
```

    ## # A tibble: 48 × 15
    ##    collection_id    access_type contact_email    contact_name  data_submission_…
    ##    <chr>            <chr>       <chr>            <chr>         <chr>            
    ##  1 6e8c5415-302c-4… READ        a.vanoudenaarde… Alexander va… 1.0              
    ##  2 0a839c4b-10d0-4… READ        zemin@pku.edu.cn Zemin Zhang   1.0              
    ##  3 ae1420fe-6630-4… READ        emukamel@ucsd.e… Eran Mukamel  1.0              
    ##  4 2a79d190-a41e-4… READ        neal.ravindra@y… Neal G. Ravi… 1.0              
    ##  5 45f0f67d-4b69-4… READ        bosiljkat@allen… Bosiljka Tas… 1.0              
    ##  6 d0e9c47b-4ce7-4… READ        emanuel.wyler@m… Emanuel Wyler 1.0              
    ##  7 5e469121-c203-4… READ        biren@ucsd.edu   Bing Ren      1.0              
    ##  8 180bff9c-c8a5-4… READ        Martin.Kampmann… Martin Kampm… 1.0              
    ##  9 4b54248f-2165-4… READ        Douglas.Strand@… Douglas Stra… 1.0              
    ## 10 367d95c0-0eb0-4… READ        edl@alleninstit… Ed S. Lein    1.0              
    ## # … with 38 more rows, and 10 more variables: description <chr>,
    ## #   genesets <lgl>, links <list>, name <chr>, obfuscated_uuid <chr>,
    ## #   visibility <chr>, created_at <date>, published_at <date>,
    ## #   revised_at <date>, updated_at <date>

``` r
datasets(db)
```

    ## # A tibble: 223 × 28
    ##    dataset_id     collection_id     assay  cell_count cell_type collection_visi…
    ##    <chr>          <chr>             <list>      <int> <list>    <chr>           
    ##  1 b07e5164-baf6… 6e8c5415-302c-49… <list…       2126 <list [1… PUBLIC          
    ##  2 9dbab10c-118d… 0a839c4b-10d0-4d… <list…    1462702 <list [1… PUBLIC          
    ##  3 1304e107-0f06… ae1420fe-6630-46… <list…       6171 <list [7… PUBLIC          
    ##  4 34575f91-6990… ae1420fe-6630-46… <list…       9876 <list [1… PUBLIC          
    ##  5 35081d47-99bf… ae1420fe-6630-46… <list…     406187 <list [1… PUBLIC          
    ##  6 50d79de5-bd17… ae1420fe-6630-46… <list…      40166 <list [7… PUBLIC          
    ##  7 5e765f97-1cf1… ae1420fe-6630-46… <list…      71183 <list [9… PUBLIC          
    ##  8 15d7a3cf-bb3a… ae1420fe-6630-46… <list…       9876 <list [1… PUBLIC          
    ##  9 31dd355c-3140… ae1420fe-6630-46… <list…      68394 <list [1… PUBLIC          
    ## 10 a9affc92-a291… ae1420fe-6630-46… <list…     159738 <list [1… PUBLIC          
    ## # … with 213 more rows, and 22 more variables: dataset_deployments <chr>,
    ## #   development_stage <list>, disease <list>, ethnicity <list>,
    ## #   is_primary_data <chr>, is_valid <lgl>, linked_genesets <lgl>,
    ## #   mean_genes_per_cell <dbl>, name <chr>, organism <list>,
    ## #   processing_status <list>, published <lgl>, revision <int>,
    ## #   schema_version <chr>, sex <list>, tissue <list>, tombstone <lgl>,
    ## #   x_normalization <chr>, created_at <date>, published_at <date>, …

``` r
files(db)
```

    ## # A tibble: 667 × 9
    ##    file_id  dataset_id filename filetype s3_uri  type  user_submitted created_at
    ##    <chr>    <chr>      <chr>    <chr>    <chr>   <chr> <lgl>          <date>    
    ##  1 8fa6b88… b07e5164-… explore… CXG      s3://h… REMIX TRUE           2021-10-27
    ##  2 90bedf1… b07e5164-… local.h… H5AD     s3://c… REMIX TRUE           2021-10-27
    ##  3 39b5c80… b07e5164-… local.r… RDS      s3://c… REMIX TRUE           2021-10-27
    ##  4 66e97f2… 9dbab10c-… local.t… RDS      s3://c… REMIX TRUE           2021-10-01
    ##  5 dd867da… 9dbab10c-… local.h… H5AD     s3://c… REMIX TRUE           2021-09-24
    ##  6 6429840… 9dbab10c-… explore… CXG      s3://h… REMIX TRUE           2021-09-24
    ##  7 ab00faf… 1304e107-… explore… CXG      s3://h… REMIX TRUE           2021-10-07
    ##  8 627f7ee… 1304e107-… local.h… H5AD     s3://c… REMIX TRUE           2021-10-07
    ##  9 f93992b… 1304e107-… local.r… RDS      s3://c… REMIX TRUE           2021-10-07
    ## 10 49072d6… 34575f91-… explore… CXG      s3://h… REMIX TRUE           2021-10-11
    ## # … with 657 more rows, and 1 more variable: updated_at <date>

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
```

    ## Rows: 1
    ## Columns: 15
    ## $ collection_id                  <chr> "8e880741-bf9a-4c8e-9227-934204631d2a"
    ## $ access_type                    <chr> "READ"
    ## $ contact_email                  <chr> "jmarshal@broadinstitute.org"
    ## $ contact_name                   <chr> "Jamie L Marshall"
    ## $ data_submission_policy_version <chr> "1.0"
    ## $ description                    <chr> "High resolution spatial transcriptomic…
    ## $ genesets                       <lgl> NA
    ## $ links                          <list> [["", "DOI", "https://doi.org/10.1101/2…
    ## $ name                           <chr> "High Resolution Slide-seqV2 Spatial Tr…
    ## $ obfuscated_uuid                <chr> ""
    ## $ visibility                     <chr> "PUBLIC"
    ## $ created_at                     <date> 2021-05-28
    ## $ published_at                   <date> 2021-12-09
    ## $ revised_at                     <date> NA
    ## $ updated_at                     <date> 2021-11-17

We can take a similar strategy to identify all datasets belonging to
this collection

``` r
left_join(
    collection_with_most_datasets |> select(collection_id),
    datasets(db),
    by = "collection_id"
)
```

    ## # A tibble: 45 × 28
    ##    collection_id     dataset_id     assay  cell_count cell_type collection_visi…
    ##    <chr>             <chr>          <list>      <int> <list>    <chr>           
    ##  1 8e880741-bf9a-4c… 4ebe33a1-c8ba… <list…      17909 <list [1… PUBLIC          
    ##  2 8e880741-bf9a-4c… a5ecb41a-d1e8… <list…      19029 <list [1… PUBLIC          
    ##  3 8e880741-bf9a-4c… 88b7da92-178d… <list…      44588 <list [1… PUBLIC          
    ##  4 8e880741-bf9a-4c… 5c451b91-eb50… <list…      13147 <list [1… PUBLIC          
    ##  5 8e880741-bf9a-4c… 3679ae7d-d70e… <list…      10701 <list [1… PUBLIC          
    ##  6 8e880741-bf9a-4c… b627552d-c205… <list…      22502 <list [9… PUBLIC          
    ##  7 8e880741-bf9a-4c… ff77ee42-ed01… <list…      38024 <list [1… PUBLIC          
    ##  8 8e880741-bf9a-4c… 2d4998cf-bd56… <list…      20866 <list [9… PUBLIC          
    ##  9 8e880741-bf9a-4c… 0738f538-ff2f… <list…      14010 <list [1… PUBLIC          
    ## 10 8e880741-bf9a-4c… 0737011b-45a6… <list…      18377 <list [9… PUBLIC          
    ## # … with 35 more rows, and 22 more variables: dataset_deployments <chr>,
    ## #   development_stage <list>, disease <list>, ethnicity <list>,
    ## #   is_primary_data <chr>, is_valid <lgl>, linked_genesets <lgl>,
    ## #   mean_genes_per_cell <dbl>, name <chr>, organism <list>,
    ## #   processing_status <list>, published <lgl>, revision <int>,
    ## #   schema_version <chr>, sex <list>, tissue <list>, tombstone <lgl>,
    ## #   x_normalization <chr>, created_at <date>, published_at <date>, …

## `facets()` provides information on ‘levels’ present in specific columns

Notice that some columns are ‘lists’ rather than atomic vectors like
‘character’ or ‘integer’.

``` r
datasets(db) |>
    select(where(is.list))
```

    ## # A tibble: 223 × 9
    ##    assay  cell_type development_sta… disease ethnicity organism processing_stat…
    ##    <list> <list>    <list>           <list>  <list>    <list>   <list>          
    ##  1 <list… <list [1… <list [4]>       <list … <list [1… <list [… <named list [11…
    ##  2 <list… <list [1… <list [65]>      <list … <list [1… <list [… <named list [11…
    ##  3 <list… <list [7… <list [1]>       <list … <list [1… <list [… <named list [11…
    ##  4 <list… <list [1… <list [1]>       <list … <list [1… <list [… <named list [11…
    ##  5 <list… <list [1… <list [1]>       <list … <list [1… <list [… <named list [11…
    ##  6 <list… <list [7… <list [1]>       <list … <list [1… <list [… <named list [11…
    ##  7 <list… <list [9… <list [1]>       <list … <list [1… <list [… <named list [11…
    ##  8 <list… <list [1… <list [1]>       <list … <list [1… <list [… <named list [11…
    ##  9 <list… <list [1… <list [1]>       <list … <list [1… <list [… <named list [11…
    ## 10 <list… <list [1… <list [1]>       <list … <list [1… <list [… <named list [11…
    ## # … with 213 more rows, and 2 more variables: sex <list>, tissue <list>

This indicates that at least some of the datasets had more than one type
of `assay`, `cell_type`, etc. The `facets()` function provides a
convenient way of discovering possible levels of each column, e.g.,
`assay`, `organism`, `ethnicity`, or `sex`, and the number of datasets
with each label.

``` r
facets(db, "assay")
```

    ## # A tibble: 21 × 4
    ##    facet label                          ontology_term_id     n
    ##    <chr> <chr>                          <chr>            <int>
    ##  1 assay 10x 3' v2                      EFO:0009899         74
    ##  2 assay 10x 3' v3                      EFO:0009922         65
    ##  3 assay Slide-seq                      EFO:0009920         45
    ##  4 assay Smart-seq2                     EFO:0008931         32
    ##  5 assay Visium Spatial Gene Expression EFO:0010961          8
    ##  6 assay Seq-Well                       EFO:0008919          7
    ##  7 assay 10x technology                 EFO:0008995          6
    ##  8 assay scATAC-seq                     EFO:0010891          5
    ##  9 assay sci-RNA-seq                    EFO:0010550          5
    ## 10 assay Smart-seq                      EFO:0008930          5
    ## # … with 11 more rows

``` r
facets(db, "ethnicity")
```

    ## # A tibble: 13 × 4
    ##    facet     label                              ontology_term_id     n
    ##    <chr>     <chr>                              <chr>            <int>
    ##  1 ethnicity European                           HANCESTRO:0005      95
    ##  2 ethnicity na                                 na                  72
    ##  3 ethnicity unknown                            unknown             72
    ##  4 ethnicity African American                   HANCESTRO:0568      24
    ##  5 ethnicity Asian                              HANCESTRO:0008      19
    ##  6 ethnicity Hispanic or Latin American         HANCESTRO:0014      13
    ##  7 ethnicity African American or Afro-Caribbean HANCESTRO:0016       5
    ##  8 ethnicity East Asian                         HANCESTRO:0009       2
    ##  9 ethnicity Chinese                            HANCESTRO:0021       1
    ## 10 ethnicity Eskimo                             HANCESTRO:0595       1
    ## 11 ethnicity Finnish                            HANCESTRO:0321       1
    ## 12 ethnicity Han Chinese                        HANCESTRO:0027       1
    ## 13 ethnicity Oceanian                           HANCESTRO:0017       1

``` r
facets(db, "sex")
```

    ## # A tibble: 3 × 4
    ##   facet label   ontology_term_id     n
    ##   <chr> <chr>   <chr>            <int>
    ## 1 sex   male    PATO:0000384       187
    ## 2 sex   female  PATO:0000383       116
    ## 3 sex   unknown unknown             36

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
        facets_filter(ethnicity, "label", "African American"),
        facets_filter(sex, "label", "female")
    )
```

There are 11 datasets satisfying our criteria. It looks like there are
up to

``` r
african_american_female |>
    summarise(total_cell_count = sum(cell_count))
```

    ## # A tibble: 1 × 1
    ##   total_cell_count
    ##              <int>
    ## 1          1661512

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

    ## # A tibble: 5 × 15
    ##   collection_id     access_type contact_email   contact_name  data_submission_p…
    ##   <chr>             <chr>       <chr>           <chr>         <chr>             
    ## 1 625f6bf4-2f33-49… READ        a5wang@health.… Allen Wang    1.0               
    ## 2 2f75d249-1bec-45… READ        rsatija@nygeno… Rahul Satija  1.0               
    ## 3 b953c942-f5d8-43… READ        icobos@stanfor… Inma Cobos    1.0               
    ## 4 b9fc3d70-5a72-44… READ        bruce.aronow@c… Bruce Aronow  1.0               
    ## 5 c9706a92-0e5f-46… READ        hnakshat@iupui… Harikrishna … 1.0               
    ## # … with 10 more variables: description <chr>, genesets <lgl>, links <list>,
    ## #   name <chr>, obfuscated_uuid <chr>, visibility <chr>, created_at <date>,
    ## #   published_at <date>, revised_at <date>, updated_at <date>

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
```

    ## # A tibble: 33 × 9
    ##    dataset_id  file_id filename filetype s3_uri  type  user_submitted created_at
    ##    <chr>       <chr>   <chr>    <chr>    <chr>   <chr> <lgl>          <date>    
    ##  1 3de0ad6d-4… eff508… explore… CXG      s3://h… REMIX TRUE           2021-10-04
    ##  2 3de0ad6d-4… 119d53… local.h… H5AD     s3://c… REMIX TRUE           2021-10-04
    ##  3 3de0ad6d-4… 030398… local.r… RDS      s3://c… REMIX TRUE           2021-10-04
    ##  4 f72958f5-7… 2e7374… local.r… RDS      s3://c… REMIX TRUE           2021-10-07
    ##  5 f72958f5-7… bbce34… explore… CXG      s3://h… REMIX TRUE           2021-10-07
    ##  6 f72958f5-7… 091323… local.h… H5AD     s3://c… REMIX TRUE           2021-10-07
    ##  7 85c60876-7… 27e511… local.h… H5AD     s3://c… REMIX TRUE           2021-09-23
    ##  8 85c60876-7… 6285ed… explore… CXG      s3://h… REMIX TRUE           2021-09-23
    ##  9 85c60876-7… c1a189… local.r… RDS      s3://c… REMIX TRUE           2021-09-23
    ## 10 9813a1d4-d… 1585f4… local.r… RDS      s3://c… REMIX TRUE           2021-09-23
    ## # … with 23 more rows, and 1 more variable: updated_at <date>

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
download the first three of our selected files.

``` r
local_files <-
    selected_files |>
    filter(filetype == "H5AD") |>
    slice(1:3) |>
    files_download(dry.run = FALSE)
basename(local_files)
```

    ## [1] "119d5332-a639-4e9e-a158-3ca1f891f337.H5AD"
    ## [2] "09132373-0ea7-4d8b-add8-9b0717781109.H5AD"
    ## [3] "27e51147-93c7-40c5-a6a3-da4b203e05ba.H5AD"

These are downloaded to a local cache (use the internal function
`cellxgenedp:::.cellxgenedb_cache_path()` for the location of the
cache), so the process is only time-consuming the first time.

`H5AD` files can be converted to *R* / *Bioconductor* objects using the
[zellkonverter](https://bioconductor.org/packages/zelkonverter) package.

``` r
h5ad <- readH5AD(local_files[[1]], reader = "R", use_hdf5 = TRUE)
h5ad
```

    ## class: SingleCellExperiment 
    ## dim: 26329 46500 
    ## metadata(4): X_normalization layer_descriptions schema_version title
    ## assays(1): X
    ## rownames: NULL
    ## rowData names(5): feature_biotype feature_id feature_is_filtered
    ##   feature_name feature_reference
    ## colnames(46500): D032_AACAAGACAGCCCACA D032_AACAGGGGTCCAGCGT ...
    ##   D231_CGAGTGCTCAACCCGG D231_TTCGCTGAGGAACATT
    ## colData names(25): assay assay_ontology_term_id ... tissue
    ##   tissue_ontology_term_id
    ## reducedDimNames(1): X_umap
    ## mainExpName: NULL
    ## altExpNames(0):

The `SingleCellExperiment` object is a matrix-like object with rows
corresponding to genes and columns to cells. Thus we can easily explore
the cells present in the data.

``` r
h5ad |>
    colData(h5ad) |>
    as_tibble() |>
    count(sex, donor)
```

    ## # A tibble: 9 × 3
    ##   sex    donor     n
    ##   <fct>  <fct> <int>
    ## 1 female D088   5903
    ## 2 female D139   5217
    ## 3 female D175   1778
    ## 4 female D231   4680
    ## 5 male   D032   4970
    ## 6 male   D046   8894
    ## 7 male   D062   4852
    ## 8 male   D122   3935
    ## 9 male   D150   6271

The [Orchestrating Single-Cell Analysis with
Bioconductor](https://bioconductor.org/books/OSCA) online resource
provides an excellent introduction to analysis and visualization of
single-cell data in *R* / *Bioconductor*. Extensive opportunities for
working with AnnData objects in *R* but using the native python
interface are briefly described in, e.g., `?AnnData2SCE` help page of
[zellkonverter](https://bioconductor.org/packages/zelkonverter).

# Session info

    ## R Under development (unstable) (2021-12-22 r81404)
    ## Platform: x86_64-apple-darwin19.6.0 (64-bit)
    ## Running under: macOS Catalina 10.15.7
    ## 
    ## Matrix products: default
    ## BLAS:   /Users/ma38727/bin/R-devel/lib/libRblas.dylib
    ## LAPACK: /Users/ma38727/bin/R-devel/lib/libRlapack.dylib
    ## 
    ## locale:
    ## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ##  [1] cellxgenedp_0.0.4           tidyr_1.1.4                
    ##  [3] dplyr_1.0.7                 SingleCellExperiment_1.17.2
    ##  [5] SummarizedExperiment_1.25.3 Biobase_2.55.0             
    ##  [7] GenomicRanges_1.47.5        GenomeInfoDb_1.31.1        
    ##  [9] IRanges_2.29.1              S4Vectors_0.33.8           
    ## [11] BiocGenerics_0.41.2         MatrixGenerics_1.7.0       
    ## [13] matrixStats_0.61.0          zellkonverter_1.5.0        
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] reticulate_1.22        tidyselect_1.1.1       xfun_0.29             
    ##  [4] HDF5Array_1.23.2       purrr_0.3.4            rhdf5_2.39.2          
    ##  [7] lattice_0.20-45        basilisk.utils_1.7.0   vctrs_0.3.8           
    ## [10] generics_0.1.1         htmltools_0.5.2        yaml_2.2.1            
    ## [13] utf8_1.2.2             rlang_0.4.12           pillar_1.6.4          
    ## [16] glue_1.6.0             GenomeInfoDbData_1.2.7 lifecycle_1.0.1       
    ## [19] stringr_1.4.0          zlibbioc_1.41.0        evaluate_0.14         
    ## [22] knitr_1.37             fastmap_1.1.0          curl_4.3.2            
    ## [25] parallel_4.2.0         fansi_0.5.0            Rcpp_1.0.7            
    ## [28] filelock_1.0.2         BiocManager_1.30.16    DelayedArray_0.21.2   
    ## [31] jsonlite_1.7.2         XVector_0.35.0         basilisk_1.7.0        
    ## [34] dir.expiry_1.3.0       png_0.1-7              digest_0.6.29         
    ## [37] stringi_1.7.6          grid_4.2.0             rhdf5filters_1.7.0    
    ## [40] cli_3.1.0              tools_4.2.0            bitops_1.0-7          
    ## [43] magrittr_2.0.1         RCurl_1.98-1.5         tibble_3.1.6          
    ## [46] crayon_1.4.2           pkgconfig_2.0.3        ellipsis_0.3.2        
    ## [49] Matrix_1.4-0           httr_1.4.2             rmarkdown_2.11        
    ## [52] Rhdf5lib_1.17.0        R6_2.5.1               compiler_4.2.0
