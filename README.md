# Installation and use

This package is available in *Bioconductor* version 3.15 and later. The
following code installs
[cellxgenedp](https://bioconductor.org/packages/cellxgenedp) as well as
other packages required for this vignette.

    pkgs <- c("cellxgenedp", "zellkonverter", "SingleCellExperiment", "HDF5Array")
    required_pkgs <- pkgs[!pkgs %in% rownames(installed.packages())]
    BiocManager::install(required_pkgs)

Use the following `pkgs` vector to install from GitHub (latest,
unchecked, development version) instead

    pkgs <- c(
        "mtmorgan/cellxgenedp", "zellkonverter", "SingleCellExperiment", "HDF5Array"
    )

Load the package into your current *R* session. We make extensive use of
the dplyr packages, and at the end of the vignette use
SingleCellExperiment and zellkonverter, so load those as well.

    suppressPackageStartupMessages({
        library(zellkonverter)
        library(SingleCellExperiment) # load early to avoid masking dplyr::count()
        library(dplyr)
        library(cellxgenedp)
    })

# Collections, datasets and files

Retrieve metadata about resources available at the cellxgene data portal
using `db()`:

    db <- db()

Printing the `db` object provides a brief overview of the available
data, as well as hints, in the form of functions like `collections()`,
for further exploration.

    db

    ## cellxgene_db
    ## number of collections(): 55
    ## number of datasets(): 327
    ## number of files(): 979

The portal organizes data hierarchically, with ‘collections’ (research
studies, approximately), ‘datasets’, and ‘files’. Discover data using
the corresponding functions.

    collections(db)

    ## # A tibble: 55 × 17
    ##    collection_id             access_type contact_email contact_name curator_name
    ##    <chr>                     <chr>       <chr>         <chr>        <chr>       
    ##  1 51544e44-293b-4c2b-8c26-… READ        vahedi@pennm… Golnaz Vahe… Maximilian …
    ##  2 6e8c5415-302c-492a-a5f9-… READ        a.vanoudenaa… Alexander v… Kirtana Vee…
    ##  3 0a839c4b-10d0-4d64-9272-… READ        zemin@pku.ed… Zemin Zhang  Pablo Garci…
    ##  4 2a79d190-a41e-4408-88c8-… READ        neal.ravindr… Neal G. Rav… Pablo Garci…
    ##  5 4b54248f-2165-477c-a027-… READ        Douglas.Stra… Douglas Str… Maximilian …
    ##  6 c9706a92-0e5f-46c1-96d8-… READ        hnakshat@iup… Harikrishna… Jennifer Yu…
    ##  7 367d95c0-0eb0-4dae-8276-… READ        edl@allenins… Ed S. Lein   Pablo Garci…
    ##  8 9b02383a-9358-4f0f-9795-… READ        parkerw@wust… Parker Wils… Jennifer Yu…
    ##  9 7d7cabfd-1d1f-40af-96b7-… READ        jimmie.ye@uc… Jimmie Ye    Maximilian …
    ## 10 8f126edf-5405-4731-8374-… READ        julian.knigh… Julian C. K… Jason Hilton
    ## # … with 45 more rows, and 12 more variables:
    ## #   data_submission_policy_version <chr>, description <chr>, genesets <lgl>,
    ## #   links <list>, name <chr>, obfuscated_uuid <chr>, publisher_metadata <list>,
    ## #   visibility <chr>, created_at <date>, published_at <date>,
    ## #   revised_at <date>, updated_at <date>

    datasets(db)

    ## # A tibble: 327 × 28
    ##    dataset_id         collection_id assay  cell_count cell_type collection_visi…
    ##    <chr>              <chr>         <list>      <int> <list>    <chr>           
    ##  1 37b21763-7f0f-41a… 51544e44-293… <list>      69645 <list>    PUBLIC          
    ##  2 b07e5164-baf6-43d… 6e8c5415-302… <list>       2126 <list>    PUBLIC          
    ##  3 9dbab10c-118d-496… 0a839c4b-10d… <list>    1462702 <list>    PUBLIC          
    ##  4 030faa69-ff79-4d8… 2a79d190-a41… <list>      77650 <list>    PUBLIC          
    ##  5 dd018fc0-8da7-403… 4b54248f-216… <list>      42127 <list>    PUBLIC          
    ##  6 2a262b59-7936-4ec… 4b54248f-216… <list>      62415 <list>    PUBLIC          
    ##  7 43770b51-4b0e-418… 4b54248f-216… <list>       5617 <list>    PUBLIC          
    ##  8 574e9f9e-f8b4-41e… 4b54248f-216… <list>      83451 <list>    PUBLIC          
    ##  9 5ba85070-a41c-418… 4b54248f-216… <list>      10742 <list>    PUBLIC          
    ## 10 03c0e874-f984-4e6… 4b54248f-216… <list>      50206 <list>    PUBLIC          
    ## # … with 317 more rows, and 22 more variables: dataset_deployments <chr>,
    ## #   development_stage <list>, disease <list>, ethnicity <list>,
    ## #   is_primary_data <chr>, is_valid <lgl>, linked_genesets <lgl>,
    ## #   mean_genes_per_cell <dbl>, name <chr>, organism <list>,
    ## #   processing_status <list>, published <lgl>, revision <int>,
    ## #   schema_version <chr>, sex <list>, tissue <list>, tombstone <lgl>,
    ## #   x_normalization <chr>, created_at <date>, published_at <date>, …

    files(db)

    ## # A tibble: 979 × 9
    ##    file_id   dataset_id filename filetype s3_uri type  user_submitted created_at
    ##    <chr>     <chr>      <chr>    <chr>    <chr>  <chr> <lgl>          <date>    
    ##  1 3a440c51… 37b21763-… local.r… RDS      s3://… REMIX TRUE           2021-09-23
    ##  2 8f87a5c3… 37b21763-… explore… CXG      s3://… REMIX TRUE           2021-09-23
    ##  3 5c64f247… 37b21763-… local.h… H5AD     s3://… REMIX TRUE           2021-09-23
    ##  4 8fa6b88d… b07e5164-… explore… CXG      s3://… REMIX TRUE           2021-10-27
    ##  5 90bedf16… b07e5164-… local.h… H5AD     s3://… REMIX TRUE           2021-10-27
    ##  6 39b5c80f… b07e5164-… local.r… RDS      s3://… REMIX TRUE           2021-10-27
    ##  7 66e97f2c… 9dbab10c-… local.t… RDS      s3://… REMIX TRUE           2021-10-01
    ##  8 dd867da2… 9dbab10c-… local.h… H5AD     s3://… REMIX TRUE           2021-09-24
    ##  9 64298402… 9dbab10c-… explore… CXG      s3://… REMIX TRUE           2021-09-24
    ## 10 0af763e1… 030faa69-… local.h… H5AD     s3://… REMIX TRUE           2021-09-23
    ## # … with 969 more rows, and 1 more variable: updated_at <date>

Each of these resources has a unique primary identifier (e.g.,
`file_id`) as well as an identifier describing the relationship of the
resource to other components of the database (e.g., `dataset_id`). These
identifiers can be used to ‘join’ information across tables.

## Using `dplyr` to navigate data

A collection may have several datasets, and datasets may have several
files. For instance, here is the collection with the most datasets

    collection_with_most_datasets <-
        datasets(db) |>
        count(collection_id, sort = TRUE) |>
        slice(1)

We can find out about this collection by joining with the
`collections()` table.

    left_join(
        collection_with_most_datasets |> select(collection_id),
        collections(db),
        by = "collection_id"
    ) |> glimpse()

    ## Rows: 1
    ## Columns: 17
    ## $ collection_id                  <chr> "8e880741-bf9a-4c8e-9227-934204631d2a"
    ## $ access_type                    <chr> "READ"
    ## $ contact_email                  <chr> "jmarshal@broadinstitute.org"
    ## $ contact_name                   <chr> "Jamie L Marshall"
    ## $ curator_name                   <chr> "Jennifer Yu-Sheng Chien"
    ## $ data_submission_policy_version <chr> "2.0"
    ## $ description                    <chr> "High resolution spatial transcriptomic…
    ## $ genesets                       <lgl> NA
    ## $ links                          <list> [["Kidney Slide-seq Github", "OTHER", "…
    ## $ name                           <chr> "High Resolution Slide-seqV2 Spatial Tr…
    ## $ obfuscated_uuid                <chr> ""
    ## $ publisher_metadata             <list> [[["Marshall", "Jamie L."], ["Noel", "T…
    ## $ visibility                     <chr> "PUBLIC"
    ## $ created_at                     <date> 2021-05-28
    ## $ published_at                   <date> 2021-12-09
    ## $ revised_at                     <date> 2022-02-07
    ## $ updated_at                     <date> 2022-02-17

We can take a similar strategy to identify all datasets belonging to
this collection

    left_join(
        collection_with_most_datasets |> select(collection_id),
        datasets(db),
        by = "collection_id"
    )

    ## # A tibble: 129 × 28
    ##    collection_id         dataset_id assay  cell_count cell_type collection_visi…
    ##    <chr>                 <chr>      <list>      <int> <list>    <chr>           
    ##  1 8e880741-bf9a-4c8e-9… 00099d5e-… <list>      26239 <list>    PUBLIC          
    ##  2 8e880741-bf9a-4c8e-9… 4ebe33a1-… <list>      17909 <list>    PUBLIC          
    ##  3 8e880741-bf9a-4c8e-9… a5ecb41a-… <list>      19029 <list>    PUBLIC          
    ##  4 8e880741-bf9a-4c8e-9… 88b7da92-… <list>      44588 <list>    PUBLIC          
    ##  5 8e880741-bf9a-4c8e-9… 5c451b91-… <list>      13147 <list>    PUBLIC          
    ##  6 8e880741-bf9a-4c8e-9… 3679ae7d-… <list>      10701 <list>    PUBLIC          
    ##  7 8e880741-bf9a-4c8e-9… b627552d-… <list>      22502 <list>    PUBLIC          
    ##  8 8e880741-bf9a-4c8e-9… ff77ee42-… <list>      38024 <list>    PUBLIC          
    ##  9 8e880741-bf9a-4c8e-9… 10eed666-… <list>      16027 <list>    PUBLIC          
    ## 10 8e880741-bf9a-4c8e-9… 2214c7a9-… <list>      27639 <list>    PUBLIC          
    ## # … with 119 more rows, and 22 more variables: dataset_deployments <chr>,
    ## #   development_stage <list>, disease <list>, ethnicity <list>,
    ## #   is_primary_data <chr>, is_valid <lgl>, linked_genesets <lgl>,
    ## #   mean_genes_per_cell <dbl>, name <chr>, organism <list>,
    ## #   processing_status <list>, published <lgl>, revision <int>,
    ## #   schema_version <chr>, sex <list>, tissue <list>, tombstone <lgl>,
    ## #   x_normalization <chr>, created_at <date>, published_at <date>, …

## `facets()` provides information on ‘levels’ present in specific columns

Notice that some columns are ‘lists’ rather than atomic vectors like
‘character’ or ‘integer’.

    datasets(db) |>
        select(where(is.list))

    ## # A tibble: 327 × 9
    ##    assay  cell_type development_sta… disease ethnicity organism processing_stat…
    ##    <list> <list>    <list>           <list>  <list>    <list>   <list>          
    ##  1 <list> <list>    <list [1]>       <list>  <list>    <list>   <named list>    
    ##  2 <list> <list>    <list [4]>       <list>  <list>    <list>   <named list>    
    ##  3 <list> <list>    <list [65]>      <list>  <list>    <list>   <named list>    
    ##  4 <list> <list>    <list [1]>       <list>  <list>    <list>   <named list [8]>
    ##  5 <list> <list>    <list [8]>       <list>  <list>    <list>   <named list>    
    ##  6 <list> <list>    <list [1]>       <list>  <list>    <list>   <named list>    
    ##  7 <list> <list>    <list [1]>       <list>  <list>    <list>   <named list>    
    ##  8 <list> <list>    <list [8]>       <list>  <list>    <list>   <named list>    
    ##  9 <list> <list>    <list [8]>       <list>  <list>    <list>   <named list>    
    ## 10 <list> <list>    <list [1]>       <list>  <list>    <list>   <named list>    
    ## # … with 317 more rows, and 2 more variables: sex <list>, tissue <list>

This indicates that at least some of the datasets had more than one type
of `assay`, `cell_type`, etc. The `facets()` function provides a
convenient way of discovering possible levels of each column, e.g.,
`assay`, `organism`, `ethnicity`, or `sex`, and the number of datasets
with each label.

    facets(db, "assay")

    ## # A tibble: 21 × 4
    ##    facet label                          ontology_term_id     n
    ##    <chr> <chr>                          <chr>            <int>
    ##  1 assay Slide-seq                      EFO:0009920        129
    ##  2 assay 10x 3' v3                      EFO:0009922         83
    ##  3 assay 10x 3' v2                      EFO:0009899         82
    ##  4 assay Smart-seq2                     EFO:0008931         32
    ##  5 assay Visium Spatial Gene Expression EFO:0010961          8
    ##  6 assay Seq-Well                       EFO:0008919          7
    ##  7 assay 10x 5' v1                      EFO:0011025          6
    ##  8 assay 10x technology                 EFO:0008995          6
    ##  9 assay scATAC-seq                     EFO:0010891          5
    ## 10 assay sci-RNA-seq                    EFO:0010550          5
    ## # … with 11 more rows

    facets(db, "ethnicity")

    ## # A tibble: 13 × 4
    ##    facet     label                              ontology_term_id     n
    ##    <chr>     <chr>                              <chr>            <int>
    ##  1 ethnicity na                                 na                 157
    ##  2 ethnicity European                           HANCESTRO:0005     103
    ##  3 ethnicity unknown                            unknown             86
    ##  4 ethnicity African American                   HANCESTRO:0568      27
    ##  5 ethnicity Asian                              HANCESTRO:0008      20
    ##  6 ethnicity Hispanic or Latin American         HANCESTRO:0014      14
    ##  7 ethnicity African American or Afro-Caribbean HANCESTRO:0016       5
    ##  8 ethnicity East Asian                         HANCESTRO:0009       2
    ##  9 ethnicity Chinese                            HANCESTRO:0021       1
    ## 10 ethnicity Eskimo                             HANCESTRO:0595       1
    ## 11 ethnicity Finnish                            HANCESTRO:0321       1
    ## 12 ethnicity Han Chinese                        HANCESTRO:0027       1
    ## 13 ethnicity Oceanian                           HANCESTRO:0017       1

    facets(db, "sex")

    ## # A tibble: 3 × 4
    ##   facet label   ontology_term_id     n
    ##   <chr> <chr>   <chr>            <int>
    ## 1 sex   male    PATO:0000384       285
    ## 2 sex   female  PATO:0000383       135
    ## 3 sex   unknown unknown             37

## Filtering faceted columns

Suppose we were interested in finding datasets from the 10x 3’ v3 assay
(`ontology_term_id` of `EFO:0009922`) containing individuals of African
American ethnicity, and female sex. Use the `facets_filter()` utility
function to filter data sets as needed

    african_american_female <-
        datasets(db) |>
        filter(
            facets_filter(assay, "ontology_term_id", "EFO:0009922"),
            facets_filter(ethnicity, "label", "African American"),
            facets_filter(sex, "label", "female")
        )

There are 14 datasets satisfying our criteria. It looks like there are
up to

    african_american_female |>
        summarise(total_cell_count = sum(cell_count))

    ## # A tibble: 1 × 1
    ##   total_cell_count
    ##              <int>
    ## 1          2246355

cells sequenced (each dataset may contain cells from several
ethnicities, as well as males or individuals of unknown gender, so we do
not know the actual number of cells available without downloading
files). Use `left_join` to identify the corresponding collections:

    ## collections
    left_join(
        african_american_female |> select(collection_id) |> distinct(),
        collections(db),
        by = "collection_id"
    )

    ## # A tibble: 6 × 17
    ##   collection_id              access_type contact_email contact_name curator_name
    ##   <chr>                      <chr>       <chr>         <chr>        <chr>       
    ## 1 c9706a92-0e5f-46c1-96d8-2… READ        hnakshat@iup… Harikrishna… Jennifer Yu…
    ## 2 2f75d249-1bec-459b-bf2b-b… READ        rsatija@nyge… Rahul Satija Pablo Garci…
    ## 3 bcb61471-2a44-4d00-a0af-f… READ        info@kpmp.org KPMP         Jennifer Yu…
    ## 4 625f6bf4-2f33-4942-962e-3… READ        a5wang@healt… Allen Wang   Pablo Garci…
    ## 5 b953c942-f5d8-434f-9da7-e… READ        icobos@stanf… Inma Cobos   Christopher…
    ## 6 b9fc3d70-5a72-4479-a046-c… READ        bruce.aronow… Bruce Aronow Pablo Garci…
    ## # … with 12 more variables: data_submission_policy_version <chr>,
    ## #   description <chr>, genesets <lgl>, links <list>, name <chr>,
    ## #   obfuscated_uuid <chr>, publisher_metadata <list>, visibility <chr>,
    ## #   created_at <date>, published_at <date>, revised_at <date>,
    ## #   updated_at <date>

# Visualizing data in `cellxgene`

Discover files associated with our first selected dataset

    selected_files <-
        left_join(
            african_american_female |> select(dataset_id),
            files(db),
            by = "dataset_id"
        )
    selected_files

    ## # A tibble: 42 × 9
    ##    dataset_id   file_id filename filetype s3_uri type  user_submitted created_at
    ##    <chr>        <chr>   <chr>    <chr>    <chr>  <chr> <lgl>          <date>    
    ##  1 de985818-28… d5c6de… local.h… H5AD     s3://… REMIX TRUE           2021-09-24
    ##  2 de985818-28… a0bcae… local.r… RDS      s3://… REMIX TRUE           2021-09-24
    ##  3 de985818-28… dff842… explore… CXG      s3://… REMIX TRUE           2021-09-24
    ##  4 f72958f5-7f… 2e7374… local.r… RDS      s3://… REMIX TRUE           2021-10-07
    ##  5 f72958f5-7f… bbce34… explore… CXG      s3://… REMIX TRUE           2021-10-07
    ##  6 f72958f5-7f… 091323… local.h… H5AD     s3://… REMIX TRUE           2021-10-07
    ##  7 07854d9c-53… f6f812… local.h… H5AD     s3://… REMIX TRUE           2022-02-15
    ##  8 07854d9c-53… 7ae7df… explore… CXG      s3://… REMIX TRUE           2022-02-15
    ##  9 07854d9c-53… 3f995f… local.r… RDS      s3://… REMIX TRUE           2022-02-15
    ## 10 0b75c598-08… 38eaca… local.h… H5AD     s3://… REMIX TRUE           2022-02-15
    ## # … with 32 more rows, and 1 more variable: updated_at <date>

The `filetype` column lists the type of each file. The cellxgene service
can be used to visualize *datasets* that have `CXG` files.

    selected_files |>
        filter(filetype == "CXG") |>
        slice(1) |> # visualize a single dataset
        datasets_visualize()

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

    local_file <-
        selected_files |>
        filter(
            dataset_id == "3de0ad6d-4378-4f62-b37b-ec0b75a50d94",
            filetype == "H5AD"
        ) |>
        files_download(dry.run = FALSE)
    basename(local_file)

    ## [1] "119d5332-a639-4e9e-a158-3ca1f891f337.H5AD"

These are downloaded to a local cache (use the internal function
`cellxgenedp:::.cellxgenedb_cache_path()` for the location of the
cache), so the process is only time-consuming the first time.

`H5AD` files can be converted to *R* / *Bioconductor* objects using the
[zellkonverter](https://bioconductor.org/packages/zelkonverter) package.

    h5ad <- readH5AD(local_file, reader = "R", use_hdf5 = TRUE)
    h5ad

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

    h5ad |>
        colData(h5ad) |>
        as_tibble() |>
        count(sex, donor)

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

    ## R Under development (unstable) (2022-03-07 r81852)
    ## Platform: aarch64-apple-darwin21.3.0 (64-bit)
    ## Running under: macOS Monterey 12.2.1
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
    ##  [1] cellxgenedp_0.99.7          dplyr_1.0.8                
    ##  [3] SingleCellExperiment_1.17.2 SummarizedExperiment_1.25.3
    ##  [5] Biobase_2.55.0              GenomicRanges_1.47.6       
    ##  [7] GenomeInfoDb_1.31.4         IRanges_2.29.1             
    ##  [9] S4Vectors_0.33.10           BiocGenerics_0.41.2        
    ## [11] MatrixGenerics_1.7.0        matrixStats_0.61.0         
    ## [13] zellkonverter_1.5.0        
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_1.0.8.2           dir.expiry_1.3.0       lattice_0.20-45       
    ##  [4] png_0.1-7              assertthat_0.2.1       digest_0.6.29         
    ##  [7] utf8_1.2.2             R6_2.5.1               evaluate_0.15         
    ## [10] httr_1.4.2             pillar_1.7.0           basilisk_1.7.0        
    ## [13] zlibbioc_1.41.0        rlang_1.0.2            curl_4.3.2            
    ## [16] Matrix_1.4-0           reticulate_1.24        rmarkdown_2.13        
    ## [19] stringr_1.4.0          RCurl_1.98-1.6         DelayedArray_0.21.2   
    ## [22] HDF5Array_1.23.2       compiler_4.2.0         xfun_0.30             
    ## [25] pkgconfig_2.0.3        htmltools_0.5.2        tidyselect_1.1.2      
    ## [28] tibble_3.1.6           GenomeInfoDbData_1.2.7 fansi_1.0.2           
    ## [31] crayon_1.5.0           bitops_1.0-7           rhdf5filters_1.7.0    
    ## [34] basilisk.utils_1.7.0   grid_4.2.0             jsonlite_1.8.0        
    ## [37] lifecycle_1.0.1        DBI_1.1.2              magrittr_2.0.2        
    ## [40] cli_3.2.0              stringi_1.7.6          XVector_0.35.0        
    ## [43] ellipsis_0.3.2         filelock_1.0.2         generics_0.1.2        
    ## [46] vctrs_0.3.8            Rhdf5lib_1.17.3        tools_4.2.0           
    ## [49] glue_1.6.2             purrr_0.3.4            parallel_4.2.0        
    ## [52] fastmap_1.1.0          yaml_2.3.5             rhdf5_2.39.6          
    ## [55] knitr_1.37
