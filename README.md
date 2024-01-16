# Introduction to cellxgenedp

The cellxgene data portal <https://cellxgene.cziscience.com/> provides
a graphical user interface to collections of single-cell sequence data
processed in standard ways to 'count matrix' summaries. The
cellxgenedp package provides an alternative, R-based inteface,
allowind data discovery, viewing, and downloading.

## Installation

This package is available in *Bioconductor* version 3.15 and
later. The following code installs
[cellxgenedp](https://bioconductor.org/packages/cellxgenedp)

``` r
if (!"BiocManager" %in% rownames(installed.packages()))
    install.packages("BiocManager", repos = "https://CRAN.R-project.org")
BiocManager::install("cellxgenedp")
```

Alternatively, install the 'development' version from GitHub

``` r
if (!"remotes" %in% rownames(installed.packages()))
    install.packages("remotes", repos = "https://CRAN.R-project.org")
remotes::install_github("mtmorgan/cellxgenedp")
```

To also install additional packages required for this vignette, use

``` r
pkgs <- c("zellkonverter", "SingleCellExperiment", "HDF5Array")
required_pkgs <- pkgs[!pkgs %in% rownames(installed.packages())]
BiocManager::install(required_pkgs)
```

## Use

Load the package into your current *R* session. We make extensive use of
the dplyr packages, and at the end of the vignette use
SingleCellExperiment and zellkonverter, so load those as well.

``` r
suppressPackageStartupMessages({
    library(dplyr)
    library(cellxgenedp)
})
```

## Shiny

`cxg()` provides a ‘shiny’ interface allowing discovery of collections
and datasets, visualization of selected datasets in the cellxgene data
portal, and download of datasets for use in R.

## Next steps

View the artcle [Discover and download datasets and files from the
cellxgene data portal][article].

[article]: https://mtmorgan.github.io/cellxgenedp/articles/using_cellxgenedp.html
