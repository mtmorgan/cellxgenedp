# Case studies

Abstract

This article summarizes short case studies and solutions arising from
user queries.

## Setup

For each case study, ensure that cellxgenedp (see the
[Bioconductor](https://bioconductor.org/packages/cellxgenedp) package
landing page, or [GitHub.io](https://mtmorgan.github.io/cellxgenedp)
site) is installed (additional installation options are at
<https://mtmorgan.github.io/cellxgenedp/>).

``` r

if (!"BiocManager" %in% rownames(installed.packages()))
    install.packages("BiocManager", repos = "https://CRAN.R-project.org")
BiocManager::install("cellxgenedp")
```

Load the package.

``` r

library(cellxgenedp)
```

## Case study: authors & datasets

### Challenge and solution

This case study arose from a question on the CZI Science Community
Slack. A user asked

> Hi! Is it possible to search CELLxGENE and identify all datasets by a
> specific author or set of authors?

Unfortunately, this is not possible from the
[CELLxGENE](https://cellxgene.cziscience.com/) web site – authors are
only associated with collections, and collections can only be sorted or
filtered by title (or publication / tissue / disease / organism).

A [cellxgenedp](https://mtmorgan.github.io/cellxgenedp) solution uses
[`authors()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md)
to discover authors and their collections, and joins this information to
[`datasets()`](https://mtmorgan.github.io/cellxgenedp/reference/query.md).

``` r

author_datasets <- left_join(
    authors(),
    datasets(),
    by = "collection_id",
    relationship = "many-to-many"
)
author_datasets
#> # A tibble: 71,715 × 39
#>    collection_id  family given consortium dataset_id dataset_version_id donor_id
#>    <chr>          <chr>  <chr> <chr>      <chr>      <chr>              <list>  
#>  1 af893e86-8e9f… Liang  Qing… NA         ed419b4e-… c8da6eeb-84d7-437… <chr>   
#>  2 af893e86-8e9f… Liang  Qing… NA         aad97cb5-… 9db639c3-5c9c-4b8… <chr>   
#>  3 af893e86-8e9f… Liang  Qing… NA         8f10185b-… 45e411d4-c103-4c2… <chr>   
#>  4 af893e86-8e9f… Liang  Qing… NA         359f7af4-… e3c7aa91-5edd-416… <chr>   
#>  5 af893e86-8e9f… Liang  Qing… NA         11ef37ee-… 5903aa1b-c323-4ae… <chr>   
#>  6 af893e86-8e9f… Liang  Qing… NA         0129dbd9-… 7f2413c4-38c2-455… <chr>   
#>  7 af893e86-8e9f… Liang  Qing… NA         00e5dedd-… 3d0dcefd-cdf2-4b1… <chr>   
#>  8 af893e86-8e9f… Cheng  Xues… NA         ed419b4e-… c8da6eeb-84d7-437… <chr>   
#>  9 af893e86-8e9f… Cheng  Xues… NA         aad97cb5-… 9db639c3-5c9c-4b8… <chr>   
#> 10 af893e86-8e9f… Cheng  Xues… NA         8f10185b-… 45e411d4-c103-4c2… <chr>   
#> # ℹ 71,705 more rows
#> # ℹ 32 more variables: assay <list>, batch_condition <list>, cell_count <int>,
#> #   cell_type <list>, citation <chr>, default_embedding <chr>,
#> #   development_stage <list>, disease <list>, embeddings <list>,
#> #   explorer_url <chr>, feature_biotype <list>, feature_count <int>,
#> #   feature_reference <list>, genetic_perturbation_strategy <lgl>,
#> #   is_pre_analysis <lgl>, is_primary_data <list>, mean_genes_per_cell <dbl>, …
```

`author_datasets` provides a convenient point from which to make basic
queries, e.g., finding the authors contributing the most datasets.

``` r

author_datasets |>
    count(family, given, sort = TRUE)
#> # A tibble: 6,797 × 3
#>    family      given        n
#>    <chr>       <chr>    <int>
#>  1 Teichmann   Sarah A.   371
#>  2 Casper      Tamara     261
#>  3 Dee         Nick       261
#>  4 Chen        Fei        258
#>  5 Murray      Evan       258
#>  6 Ding        Song-Lin   257
#>  7 Lein        Ed S.      253
#>  8 Keene       C. Dirk    252
#>  9 Hirschstein Daniel     241
#> 10 Macosko     Evan Z.    240
#> # ℹ 6,787 more rows
```

Perhaps one is interested in the most prolific authors based on
‘collections’, rather than ‘datasets’. The five most prolific authors by
collection are

``` r

prolific_authors <-
    authors() |>
    count(family, given, sort = TRUE) |>
    slice(1:5)
prolific_authors
#> # A tibble: 5 × 3
#>   family    given          n
#>   <chr>     <chr>      <int>
#> 1 Teichmann Sarah A.      37
#> 2 NA        NA            21
#> 3 Meyer     Kerstin B.    18
#> 4 Polanski  Krzysztof     17
#> 5 Regev     Aviv          17
```

The datasets associated with authors are

``` r

right_join(
    author_datasets,
    prolific_authors,
    by = c("family", "given")
)
#> # A tibble: 1,005 × 40
#>    collection_id  family given consortium dataset_id dataset_version_id donor_id
#>    <chr>          <chr>  <chr> <chr>      <chr>      <chr>              <list>  
#>  1 16876983-d454… NA     NA    Global Pa… e88a8e7c-… 02e1d36f-3019-49c… <chr>   
#>  2 16876983-d454… NA     NA    Global Pa… 5fa72b3e-… 5451683b-f184-4bd… <chr>   
#>  3 e75342a8-0f3b… Teich… Sara… NA         f7995301-… 27fdbdf9-deae-4ae… <chr>   
#>  4 e75342a8-0f3b… Teich… Sara… NA         ed2b673b-… 9b7c7203-91cd-4e8… <chr>   
#>  5 e75342a8-0f3b… Teich… Sara… NA         bdf69f8d-… f8a5ecd6-51ef-4b3… <chr>   
#>  6 e75342a8-0f3b… Teich… Sara… NA         9434b020-… 48b2a43b-b04c-41c… <chr>   
#>  7 e75342a8-0f3b… Teich… Sara… NA         83b5e943-… 73b3b585-499e-433… <chr>   
#>  8 e75342a8-0f3b… Teich… Sara… NA         65badd7a-… 6d0b8b8a-2b22-457… <chr>   
#>  9 e75342a8-0f3b… Teich… Sara… NA         1252c5fb-… 20080edf-b3c5-4d1… <chr>   
#> 10 e75342a8-0f3b… Teich… Sara… NA         1062c0f2-… 7206e56c-a6f9-45c… <chr>   
#> # ℹ 995 more rows
#> # ℹ 33 more variables: assay <list>, batch_condition <list>, cell_count <int>,
#> #   cell_type <list>, citation <chr>, default_embedding <chr>,
#> #   development_stage <list>, disease <list>, embeddings <list>,
#> #   explorer_url <chr>, feature_biotype <list>, feature_count <int>,
#> #   feature_reference <list>, genetic_perturbation_strategy <lgl>,
#> #   is_pre_analysis <lgl>, is_primary_data <list>, mean_genes_per_cell <dbl>, …
```

Alternatively, one might be interested in specific authors. This is most
easily accomplished with a simple filter on `author_datasets`, e.g.,

``` r

author_datasets |>
    filter(
        family %in% c("Teichmann", "Regev", "Haniffa")
    )
#> # A tibble: 658 × 39
#>    collection_id  family given consortium dataset_id dataset_version_id donor_id
#>    <chr>          <chr>  <chr> <chr>      <chr>      <chr>              <list>  
#>  1 e75342a8-0f3b… Teich… Sara… NA         f7995301-… 27fdbdf9-deae-4ae… <chr>   
#>  2 e75342a8-0f3b… Teich… Sara… NA         ed2b673b-… 9b7c7203-91cd-4e8… <chr>   
#>  3 e75342a8-0f3b… Teich… Sara… NA         bdf69f8d-… f8a5ecd6-51ef-4b3… <chr>   
#>  4 e75342a8-0f3b… Teich… Sara… NA         9434b020-… 48b2a43b-b04c-41c… <chr>   
#>  5 e75342a8-0f3b… Teich… Sara… NA         83b5e943-… 73b3b585-499e-433… <chr>   
#>  6 e75342a8-0f3b… Teich… Sara… NA         65badd7a-… 6d0b8b8a-2b22-457… <chr>   
#>  7 e75342a8-0f3b… Teich… Sara… NA         1252c5fb-… 20080edf-b3c5-4d1… <chr>   
#>  8 e75342a8-0f3b… Teich… Sara… NA         1062c0f2-… 7206e56c-a6f9-45c… <chr>   
#>  9 e75342a8-0f3b… Teich… Sara… NA         0fdb6122-… 18111333-e7ce-4a1… <chr>   
#> 10 32f2fd23-ec74… Teich… Sara… NA         9ddea8d9-… e9c1bce2-a784-4ac… <chr>   
#> # ℹ 648 more rows
#> # ℹ 32 more variables: assay <list>, batch_condition <list>, cell_count <int>,
#> #   cell_type <list>, citation <chr>, default_embedding <chr>,
#> #   development_stage <list>, disease <list>, embeddings <list>,
#> #   explorer_url <chr>, feature_biotype <list>, feature_count <int>,
#> #   feature_reference <list>, genetic_perturbation_strategy <lgl>,
#> #   is_pre_analysis <lgl>, is_primary_data <list>, mean_genes_per_cell <dbl>, …
```

or more carefully by constructing a `data.frame` of family and given
names, and performing a join with `author_datasets`

``` r

authors_of_interest <-
    tibble(
        family = c("Teichmann", "Regev", "Haniffa"),
        given = c("Sarah A.", "Aviv", "Muzlifah")
    )
right_join(
    author_datasets,
    authors_of_interest,
    by = c("family", "given")
)
#> # A tibble: 582 × 39
#>    collection_id  family given consortium dataset_id dataset_version_id donor_id
#>    <chr>          <chr>  <chr> <chr>      <chr>      <chr>              <list>  
#>  1 e75342a8-0f3b… Teich… Sara… NA         f7995301-… 27fdbdf9-deae-4ae… <chr>   
#>  2 e75342a8-0f3b… Teich… Sara… NA         ed2b673b-… 9b7c7203-91cd-4e8… <chr>   
#>  3 e75342a8-0f3b… Teich… Sara… NA         bdf69f8d-… f8a5ecd6-51ef-4b3… <chr>   
#>  4 e75342a8-0f3b… Teich… Sara… NA         9434b020-… 48b2a43b-b04c-41c… <chr>   
#>  5 e75342a8-0f3b… Teich… Sara… NA         83b5e943-… 73b3b585-499e-433… <chr>   
#>  6 e75342a8-0f3b… Teich… Sara… NA         65badd7a-… 6d0b8b8a-2b22-457… <chr>   
#>  7 e75342a8-0f3b… Teich… Sara… NA         1252c5fb-… 20080edf-b3c5-4d1… <chr>   
#>  8 e75342a8-0f3b… Teich… Sara… NA         1062c0f2-… 7206e56c-a6f9-45c… <chr>   
#>  9 e75342a8-0f3b… Teich… Sara… NA         0fdb6122-… 18111333-e7ce-4a1… <chr>   
#> 10 32f2fd23-ec74… Teich… Sara… NA         9ddea8d9-… e9c1bce2-a784-4ac… <chr>   
#> # ℹ 572 more rows
#> # ℹ 32 more variables: assay <list>, batch_condition <list>, cell_count <int>,
#> #   cell_type <list>, citation <chr>, default_embedding <chr>,
#> #   development_stage <list>, disease <list>, embeddings <list>,
#> #   explorer_url <chr>, feature_biotype <list>, feature_count <int>,
#> #   feature_reference <list>, genetic_perturbation_strategy <lgl>,
#> #   is_pre_analysis <lgl>, is_primary_data <list>, mean_genes_per_cell <dbl>, …
```

### Areas of interest

There are several interesting questions that suggest themselves, and
several areas where some additional work is required.

It might be interesting to identify authors working on similar disease,
or other areas of interest. The `disease` column in the
`author_datasets` table is a list.

``` r

author_datasets |>
    select(family, given, dataset_id, disease)
#> # A tibble: 71,715 × 4
#>    family given   dataset_id                           disease   
#>    <chr>  <chr>   <chr>                                <list>    
#>  1 Liang  Qingnan ed419b4e-db9b-40f1-8593-68fdf8dfb076 <list [1]>
#>  2 Liang  Qingnan aad97cb5-f375-45ef-ae9d-178e7f5d5180 <list [1]>
#>  3 Liang  Qingnan 8f10185b-e0b3-46a5-8706-7f1799225d79 <list [1]>
#>  4 Liang  Qingnan 359f7af4-87d4-4117-9d6c-ca4cfa1f3f0b <list [1]>
#>  5 Liang  Qingnan 11ef37ee-2173-458e-aab8-7fe35da8e47b <list [1]>
#>  6 Liang  Qingnan 0129dbd9-a7d3-4f6b-96b9-1da155a93748 <list [1]>
#>  7 Liang  Qingnan 00e5dedd-b9b7-43be-8c28-b0e5c6414a62 <list [1]>
#>  8 Cheng  Xuesen  ed419b4e-db9b-40f1-8593-68fdf8dfb076 <list [1]>
#>  9 Cheng  Xuesen  aad97cb5-f375-45ef-ae9d-178e7f5d5180 <list [1]>
#> 10 Cheng  Xuesen  8f10185b-e0b3-46a5-8706-7f1799225d79 <list [1]>
#> # ℹ 71,705 more rows
```

This is because a single dataset may involve more than one disease.
Furthermore, each entry in the list contains two elements, the `label`
and `ontology_term_id` of the disease. There are two approaches to
working with this data.

One approach to working with this data uses facilities in
[cellxgenedp](https://mtmorgan.github.io/cellxgenedp) as outlined in an
accompanying article. Discover possible diseases.

``` r

facets(db(), "disease")
#> # A tibble: 311 × 4
#>    facet   label                                        ontology_term_id     n
#>    <chr>   <chr>                                        <chr>            <int>
#>  1 disease normal                                       PATO:0000461      1782
#>  2 disease COVID-19                                     MONDO:0100096       66
#>  3 disease dementia                                     MONDO:0001627       52
#>  4 disease breast cancer                                MONDO:0007254       38
#>  5 disease colorectal cancer                            MONDO:0005575       35
#>  6 disease myocardial infarction                        MONDO:0005068       30
#>  7 disease Alzheimer disease                            MONDO:0004975       26
#>  8 disease diabetic kidney disease                      MONDO:0005016       26
#>  9 disease autosomal dominant polycystic kidney disease MONDO:0004691       24
#> 10 disease Crohn disease                                MONDO:0005011       21
#> # ℹ 301 more rows
```

Focus on `COVID-19`, and use
[`facets_filter()`](https://mtmorgan.github.io/cellxgenedp/reference/facets.md)
to select relevant author-dataset combinations.

``` r

author_datasets |>
    filter(facets_filter(disease, "label", "COVID-19"))
#> # A tibble: 1,912 × 39
#>    collection_id  family given consortium dataset_id dataset_version_id donor_id
#>    <chr>          <chr>  <chr> <chr>      <chr>      <chr>              <list>  
#>  1 29f92179-ca10… Szabo  Pete… NA         f156606a-… d459ceb2-d44f-469… <chr>   
#>  2 29f92179-ca10… Szabo  Pete… NA         eec804b9-… 8f00b78c-fef9-438… <chr>   
#>  3 29f92179-ca10… Szabo  Pete… NA         eeacb0c1-… 9db81723-ba1e-487… <chr>   
#>  4 29f92179-ca10… Szabo  Pete… NA         ed9e9f96-… 15d019f7-e436-41d… <chr>   
#>  5 29f92179-ca10… Szabo  Pete… NA         ea786a06-… 01770d4d-850a-478… <chr>   
#>  6 29f92179-ca10… Szabo  Pete… NA         e5f5d954-… c3570ea2-1c92-44b… <chr>   
#>  7 29f92179-ca10… Szabo  Pete… NA         dbf0bd35-… 0a7b023c-faeb-41e… <chr>   
#>  8 29f92179-ca10… Szabo  Pete… NA         db59611b-… b0f4a940-ac61-4e8… <chr>   
#>  9 29f92179-ca10… Szabo  Pete… NA         ce009dc1-… dfa1787b-751e-414… <chr>   
#> 10 29f92179-ca10… Szabo  Pete… NA         cab0bc48-… a9a647bf-00ee-4e3… <chr>   
#> # ℹ 1,902 more rows
#> # ℹ 32 more variables: assay <list>, batch_condition <list>, cell_count <int>,
#> #   cell_type <list>, citation <chr>, default_embedding <chr>,
#> #   development_stage <list>, disease <list>, embeddings <list>,
#> #   explorer_url <chr>, feature_biotype <list>, feature_count <int>,
#> #   feature_reference <list>, genetic_perturbation_strategy <lgl>,
#> #   is_pre_analysis <lgl>, is_primary_data <list>, mean_genes_per_cell <dbl>, …
```

Authors contributing to these datasets are

``` r

author_datasets |>
    filter(facets_filter(disease, "label", "COVID-19")) |>
    count(family, given, sort = TRUE)
#> # A tibble: 836 × 3
#>    family       given           n
#>    <chr>        <chr>       <int>
#>  1 Farber       Donna L.       29
#>  2 Guo          Xinzheng V.    28
#>  3 Saqi         Anjali         28
#>  4 Baldwin      Matthew R.     27
#>  5 Chait        Michael        27
#>  6 Connors      Thomas J.      27
#>  7 Davis-Porada Julia          27
#>  8 Dogra        Pranay         27
#>  9 Gray         Joshua I.      27
#> 10 Idzikowski   Emma           27
#> # ℹ 826 more rows
```

A second approach is to follow the practices in [R for Data
Science](https://r4ds.hadley.nz/rectangling), the `disease` column can
be ‘unnested’ twice, the first time to expand the `author_datasets`
table for each disease, and the second time to separate the two columns
of each disease.

``` r

author_dataset_diseases <-
    author_datasets |>
    select(family, given, dataset_id, disease) |>
    tidyr::unnest_longer(disease) |>
    tidyr::unnest_wider(disease)
author_dataset_diseases
#> # A tibble: 100,110 × 5
#>    family given   dataset_id                           label  ontology_term_id
#>    <chr>  <chr>   <chr>                                <chr>  <chr>           
#>  1 Liang  Qingnan ed419b4e-db9b-40f1-8593-68fdf8dfb076 normal PATO:0000461    
#>  2 Liang  Qingnan aad97cb5-f375-45ef-ae9d-178e7f5d5180 normal PATO:0000461    
#>  3 Liang  Qingnan 8f10185b-e0b3-46a5-8706-7f1799225d79 normal PATO:0000461    
#>  4 Liang  Qingnan 359f7af4-87d4-4117-9d6c-ca4cfa1f3f0b normal PATO:0000461    
#>  5 Liang  Qingnan 11ef37ee-2173-458e-aab8-7fe35da8e47b normal PATO:0000461    
#>  6 Liang  Qingnan 0129dbd9-a7d3-4f6b-96b9-1da155a93748 normal PATO:0000461    
#>  7 Liang  Qingnan 00e5dedd-b9b7-43be-8c28-b0e5c6414a62 normal PATO:0000461    
#>  8 Cheng  Xuesen  ed419b4e-db9b-40f1-8593-68fdf8dfb076 normal PATO:0000461    
#>  9 Cheng  Xuesen  aad97cb5-f375-45ef-ae9d-178e7f5d5180 normal PATO:0000461    
#> 10 Cheng  Xuesen  8f10185b-e0b3-46a5-8706-7f1799225d79 normal PATO:0000461    
#> # ℹ 100,100 more rows
```

Author-dataset combinations associated with COVID-19, and contributors
to these datasets, are

``` r

author_dataset_diseases |>
    filter(label == "COVID-19")

author_dataset_diseases |>
    filter(label == "COVID-19") |>
    count(family, given, sort = TRUE)
```

These computations are the same as the earlier iteration using
functionality in [cellxgenedp](https://mtmorgan.github.io/cellxgenedp).

A further resource that might be of interest is the \[OSLr\]\[\] package
article illustrating how the ontologies used by CELLxGENE can be
manipulated to, e.g., identify studies with terms that derive from a
common term (e.g., all disease terms related to ‘carcinoma’).

### Collaboration

TODO.

It might be interesting to know which authors have collaborated with one
another. This can be computed from the `author_datasets` table,
following approaches developed in the
[grantpubcite](https://mtmorgan.github.io/grant) package to identify
collaborations between projects in the NIH-funded ITCR program. See the
graph visualization in the [ITCR
collaboration](https://mtmorgan.github.io/grantpubcite/articles/case_study_itcr.html#itcr-collaboration)
section for inspiration.

### Duplicate collection-author combinations

Here are the authors

``` r

authors <- authors()
authors
#> # A tibble: 9,104 × 4
#>    collection_id                        family  given    consortium
#>    <chr>                                <chr>   <chr>    <chr>     
#>  1 af893e86-8e9f-41f1-a474-ef05359b1fb7 Liang   Qingnan  NA        
#>  2 af893e86-8e9f-41f1-a474-ef05359b1fb7 Cheng   Xuesen   NA        
#>  3 af893e86-8e9f-41f1-a474-ef05359b1fb7 Wang    Jun      NA        
#>  4 af893e86-8e9f-41f1-a474-ef05359b1fb7 Owen    Leah     NA        
#>  5 af893e86-8e9f-41f1-a474-ef05359b1fb7 Shakoor Akbar    NA        
#>  6 af893e86-8e9f-41f1-a474-ef05359b1fb7 Lillvis John L.  NA        
#>  7 af893e86-8e9f-41f1-a474-ef05359b1fb7 Zhang   Charles  NA        
#>  8 af893e86-8e9f-41f1-a474-ef05359b1fb7 Farkas  Michael  NA        
#>  9 af893e86-8e9f-41f1-a474-ef05359b1fb7 Kim     Ivana K. NA        
#> 10 af893e86-8e9f-41f1-a474-ef05359b1fb7 Li      Yumei    NA        
#> # ℹ 9,094 more rows
```

There are 9104 collection-author combinations. We expect these to be
distinct (each row identifying a unique collection-author combination).
But this is not true

``` r

nrow(authors) == nrow(distinct(authors))
#> [1] FALSE
```

Duplicated data are

``` r

authors |> 
    count(collection_id, family, given, consortium, sort = TRUE) |>
    filter(n > 1)
#> # A tibble: 24 × 5
#>    collection_id                        family   given      consortium     n
#>    <chr>                                <chr>    <chr>      <chr>      <int>
#>  1 51544e44-293b-4c2b-8c26-560678423380 Betts    Michael R. NA             2
#>  2 51544e44-293b-4c2b-8c26-560678423380 Faryabi  Robert B.  NA             2
#>  3 51544e44-293b-4c2b-8c26-560678423380 Fasolino Maria      NA             2
#>  4 51544e44-293b-4c2b-8c26-560678423380 Feldman  Michael    NA             2
#>  5 51544e44-293b-4c2b-8c26-560678423380 Goldman  Naomi      NA             2
#>  6 51544e44-293b-4c2b-8c26-560678423380 Golson   Maria L.   NA             2
#>  7 51544e44-293b-4c2b-8c26-560678423380 Japp     Alberto S. NA             2
#>  8 51544e44-293b-4c2b-8c26-560678423380 Kaestner Klaus H.   NA             2
#>  9 51544e44-293b-4c2b-8c26-560678423380 Kondo    Ayano      NA             2
#> 10 51544e44-293b-4c2b-8c26-560678423380 Liu      Chengyang  NA             2
#> # ℹ 14 more rows
```

Discover details of the first duplicated collection,
`e5f58829-1a66-40b5-a624-9046778e74f5`

``` r

duplicate_authors <-
    collections() |>
    filter(collection_id == "e5f58829-1a66-40b5-a624-9046778e74f5")
duplicate_authors
#> # A tibble: 1 × 19
#>   collection_id     collection_version_id collection_url consortia contact_email
#>   <chr>             <chr>                 <chr>          <list>    <chr>        
#> 1 e5f58829-1a66-40… 61d34250-a255-4c7c-b… https://cellx… <chr [2]> angela.olive…
#> # ℹ 14 more variables: contact_name <chr>, curator_name <chr>,
#> #   description <chr>, doi <chr>, is_pre_analysis <lgl>, links <list>,
#> #   name <chr>, publisher_metadata <list>, revising_in <lgl>,
#> #   revision_of <lgl>, visibility <chr>, created_at <date>,
#> #   published_at <date>, revised_at <date>
```

The author information comes from the `publisher_metadata` column

``` r

publisher_metadata <-
    duplicate_authors |>
    pull(publisher_metadata)
```

This is a ‘list-of-lists’, with relevant information as elements in the
first list

``` r

names(publisher_metadata[[1]])
#> [1] "authors"         "is_preprint"     "journal"         "published_at"   
#> [5] "published_day"   "published_month" "published_year"
```

and relevant information in the `authors` field, of which there are 221

``` r

length(publisher_metadata[[1]][["authors"]])
#> [1] 164
```

Inspection shows that there are four authors with family name `Pisco`
and given name `Angela Oliveira`: it appears that the data provided by
CZI indeed includes duplicate author names.

From a pragmatic perspective, it might make sense to remove duplicate
entries from `authors` before down-stream analysis.

``` r

deduplicated_authors <- distinct(authors)
```

Tools that I have found useful when working with list-of-lists style
data rare
[listviewer::jsonedit()](https://CRAN.r-project.org/package=listviewer)
for visualization, and
[rjsoncons](https://CRAN.r-project.org/package=rjsoncons) for filtering
and querying these data using JSONpointer, JSONpath, or JMESpath
expression (a more R-centric tool is the
[purrr](https://CRAN.r-project.org/package=purrr) package).

#### What is an ‘author’?

The combination of family and given name may refer to two (or more)
different individuals (e.g., two individuals named ‘Martin Morgan’), or
a single individual may be recorded under two different names (e.g.,
given name sometimes ‘Martin’ and sometimes ‘Martin T.’). It is not
clear how this could be resolved; recording ORCID identifiers migth help
with disambiguation.

## Case study: using ontology to identify datasets

This case study was developed in response to the following Slack
question:

> CELLxGENE’s webpage is using different ontologies and displaying them
> in an easy to interogate manner (choosing amongst 3 possible
> coarseness for cell types, tissues and age) I was wondering if this
> simplified tree of the 3 subgroups for cell type, tissue and age
> categories was available somewhere?

As indicated in the question, CELLxGENE provides some access to
ontologies through a hand-curated three-tiered classification of
specific facets; the tiers can be retrieved from publicly available
code, but one might want to develop a more flexible or principled
approach.

CELLxGENE dataset facets like ‘disease’ and ‘cell type’ use terms from
ontologies. Ontologies arrange terms in directed acyclic graphs, and use
of ontologies can be useful to identify related datasets. For instance,
one might be interested in cancer-related datasets (derived from the
‘carcinoma’ term in the corresponding ontology) in general, rather than,
e.g., ‘B-cell non-Hodgkins lymphoma’.

In exploring this question in *R*, I found myself developing the
[OLSr](https://mtmorgan.github.io/OLSr) package to query and process
ontologies from the EMBL-EBI [Ontology Lookup
Service](https://www.ebi.ac.uk/ols4/). See the ‘[Case Study: CELLxGENE
Ontologies](https://mtmorgan.github.io/OLSr/articles/b_case_study_cxg.html)’
article in the OLSr package for full details.

## Session information

    #> R version 4.6.0 (2026-04-24)
    #> Platform: x86_64-pc-linux-gnu
    #> Running under: Ubuntu 24.04.4 LTS
    #> 
    #> Matrix products: default
    #> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    #> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
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
    #> [1] stats     graphics  grDevices utils     datasets  methods   base     
    #> 
    #> other attached packages:
    #> [1] cellxgenedp_1.17.1 dplyr_1.2.1        BiocStyle_2.40.0  
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] sass_0.4.10         utf8_1.2.6          generics_0.1.4     
    #>  [4] tidyr_1.3.2         digest_0.6.39       magrittr_2.0.5     
    #>  [7] evaluate_1.0.5      bookdown_0.46       fastmap_1.2.0      
    #> [10] jsonlite_2.0.0      promises_1.5.0      BiocManager_1.30.27
    #> [13] httr_1.4.8          purrr_1.2.2         textshaping_1.0.5  
    #> [16] jquerylib_0.1.4     cli_3.6.6           shiny_1.13.0       
    #> [19] rlang_1.2.0         withr_3.0.2         cachem_1.1.0       
    #> [22] yaml_2.3.12         otel_0.2.0          tools_4.6.0        
    #> [25] httpuv_1.6.17       DT_0.34.0           curl_7.1.0         
    #> [28] vctrs_0.7.3         rjsoncons_1.3.3     R6_2.6.1           
    #> [31] mime_0.13           lifecycle_1.0.5     fs_2.1.0           
    #> [34] htmlwidgets_1.6.4   ragg_1.5.2          pkgconfig_2.0.3    
    #> [37] desc_1.4.3          pkgdown_2.2.0       pillar_1.11.1      
    #> [40] bslib_0.11.0        later_1.4.8         glue_1.8.1         
    #> [43] Rcpp_1.1.1-1.1      systemfonts_1.3.2   xfun_0.58          
    #> [46] tibble_3.3.1        tidyselect_1.2.1    knitr_1.51         
    #> [49] xtable_1.8-8        htmltools_0.5.9     rmarkdown_2.31     
    #> [52] compiler_4.6.0
