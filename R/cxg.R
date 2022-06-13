#' @importFrom dplyr filter slice summarize left_join
#'
#' @importFrom shiny actionButton hr icon navbarPage observeEvent
#'     renderText runGadget stopApp tabPanel textOutput
#'     updateNavbarPage
#'
#' @importFrom DT renderDataTable datatable formatStyle

##
## utilities
##

.cxg_download_cache <- local({
    files <- new.env(parent = emptyenv())
    list(reset = function() {
        rm(list = ls(files), envir = files)
    }, toggle = function(id) {
        if (exists(id, envir = files)) {
            rm(list = id, envir = files)
        } else {
            assign(id, TRUE, envir = files)
        }
    }, ls = function() {
        ls(files)
    })
})

.cxg_labels <-
    function(x)
{
    vapply(x, function(elt) {
        labels <- vapply(elt, `[[`, character(1), "label")
        paste(labels, collapse = ", ")
    }, character(1))
}

## collections() / datasets() / files()

.cxg_collections <-
    function(db)
{
    collections <- collections(db) |>
        select(c("collection_id", "name", "publisher_metadata")) |>
        mutate(authors = vapply(publisher_metadata, function(x) {
            if (length(x)==1)
                return(NA_character_)
            author_list <- x$authors
            family <- unlist(lapply(author_list, `[[`, "family"))
            given <- unlist(lapply(author_list, `[[`, "given"))
            paste(family, given, sep = ", ", collapse = "; ")
        }, character(1))) |>
        mutate(publication_date = vapply(publisher_metadata, function(x) {
            unlist(x["published_year"])
        }, integer(1)))

    datasets <-
        datasets(db) |>
        select(
            "collection_id", "organism", "tissue", "disease", "assay",
            "cell_count", "cell_type", "development_stage", "ethnicity",
            "mean_genes_per_cell", "sex"
        )

    labeledDat <-
        datasets |>
        mutate(
            across(c("organism", "tissue", "disease", "assay", "cell_type",
                "development_stage", "ethnicity", "sex"), .cxg_labels)
        ) |>
        group_by(.data$collection_id) |>
        summarize(across(
            c("organism", "tissue", "disease", "assay", "cell_type",
                "development_stage", "ethnicity", "sex"),
            function(x) paste(unique(x), collapse = ", ")
        ))

    countDat <- datasets |>
        group_by(.data$collection_id) |>
        summarize(cell_count = sum(.data$cell_count))

    allDat <-
        left_join(collections, labeledDat, by = "collection_id") |>
        left_join(countDat, by = "collection_id")

    allDat
}

.cxg_datasets <-
    function(db)
{
    ## select tbl
    datasets <- datasets(db) |>
        mutate(
            across(c("organism", "tissue", "disease", "assay", "cell_type",
                "development_stage", "ethnicity", "sex"), .cxg_labels),
            cell_count = as.numeric(.data$cell_count),
            view = as.character(icon("eye-open", lib = "glyphicon"))
        ) |>
        select(
            "dataset_id", "collection_id", "view", "name", "organism", "tissue",
            "disease", "assay", "cell_count", "cell_type", "development_stage",
            "ethnicity", "mean_genes_per_cell", "sex"
        )

    datasets
}

.cxg_files <-
    function(db, id)
{
    tbl <- files(db)

    if (!is.null(id))
        tbl <- tbl |> dplyr::filter(.data$dataset_id == id)
    tbl
}

## *_format() for display

.cxg_collections_format <-
    function(tbl)
{
    db <- db()

    dt <- datatable(
        tbl,
        selection = 'single',
        extensions = c('SearchPanes'),
        escape = FALSE,
        colnames = c(
            'rownames', 'id', 'Collection', 'metadata', 'Authors', 'Publication Date',
            'Organism', 'Tissue', 'Disease', 'Assay', 'Cell Type',
            'Development Stage', 'Ethnicity', 'Sex', 'Cells'
        ),
        options = list(
            scrollX = TRUE,
            scrollY = 400,
            dom = 'Pfrtip',
            searchPanes = list(
                order = c('Assay', 'Authors', 'Cell Type', 'Development Stage',
                    'Disease', 'Ethnicity', 'Organism', 'Publication Date',
                    'Sex', 'Tissue')
            ),
            columnDefs = list(
                .cxg_search_panes(db, "organism", 6),
                .cxg_search_panes(db, "disease", 8),
                .cxg_search_panes(db, "tissue", 7),
                .cxg_search_panes(db, "assay", 9),
                .cxg_search_panes(db, "authors", 4, .cxg_search_panes_author),
                .cxg_search_panes(db, "cell_type", 10),
                .cxg_search_panes(db, "development_stage", 11),
                .cxg_search_panes(db, "ethnicity", 12),
                .cxg_search_panes(db, "publication_date", 5, .cxg_search_panes_publication_date),
                .cxg_search_panes(db, "sex", 13),
                list(
                    searchPanes = list(show = FALSE), targets = c(0:4, 14)
                ),
                list(visible = FALSE, targets = c(0:1, 3:5, 10:13)),
                list(width = '20px', targets = 5:8)
            )
        )
    )
    formatStyle(dt, 2:7, 'vertical-align' = 'top')
}

.cxg_search_panes_publication_date <-
    function(db, type)
{
    year <- sort(unlist(unique(jmespath(db, "[].publisher_metadata.published_year") |> parse_json())))
}

.cxg_search_panes_author <- 
    function(db, type)
{
     family <- unlist(jmespath(db, "[].publisher_metadata.authors[].family") |> parse_json())
     given <- unlist((jmespath(db, "[].publisher_metadata.authors[].given") |> parse_json()))
     unique(paste(family, given, sep = ", "))
}

.cxg_search_panes <-
    function(db, type, col, label_fun = NULL)
{
    if (is.null(label_fun))
        data_labels <- facets(db, type)$label
    else
        data_labels <- label_fun(db, type)
    data_select <- lapply(data_labels, function(data_label) {
        list(label = data_label,
            value = JS(paste0("function(rowData, rowIdx) { return /", data_label,
                "/.test(rowData[", col, "]); }"))
        )
    })
    list(
        searchPanes = list(
            show = TRUE,
            options = data_select,
            initCollapsed = TRUE,
            cascadePanes = TRUE
        ),
        targets = col
    )
}

.cxg_datasets_format <-
    function(tbl)
{
    db <- db()
    
    dt <- datatable(
        tbl,
        selection = 'none',
        extensions = c('Select', 'SearchPanes'),
        escape = FALSE,
        colnames = c(
            'rownames', 'dataset_id', 'collection_id', 'View', 'Dataset',
            'Organism', 'Tissue', 'Disease', 'Assay',
            'Cells', 'Cell Type', 'Development Stage', 'Ethnicity', 'Gene Count',
            'Sex'
        ),
        options = list(
            scrollX = TRUE,
            scrollY = 400,
            dom = 'Pfrtip',
            searchPanes = list(
                #layout = 'columns-1',
                order = c('Assay', 'Cell Type', 'Development Stage', 'Disease',
                    'Ethnicity', 'Organism', 'Tissue', 'Sex')
            ),
            columnDefs = list(
                .cxg_search_panes(db, "organism", 5),
                .cxg_search_panes(db, "disease", 7),
                .cxg_search_panes(db, "tissue", 6),
                .cxg_search_panes(db, "assay", 8),
                .cxg_search_panes(db, "cell_type", 10),
                .cxg_search_panes(db, "development_stage", 11),
                .cxg_search_panes(db, "ethnicity", 12),
                .cxg_search_panes(db, "sex", 14),
                list(
                    searchPanes = list(show = FALSE), targets = c(0:4, 9, 13)
                ),
                list(visible = FALSE, targets = c(0:2, 10:14)),
                list(className = 'dt-center', width = "10px", targets = 3)
            )
            #dom = '<"dtsp-dataTable"frtip>'
        )
    )
    formatStyle(dt, 3:9, 'vertical-align' = "top")

}

## download helpers

.cxg_download <-
    function(dataset_ids, convert)
{
    if (!length(dataset_ids))
        return(character(0))

    message(
        "Downloading ", if (convert) "& converting ",
        length(dataset_ids), " datasets"
    )
    db <- db(overwrite = FALSE)
    files(db) |>
        filter(
            .data$dataset_id %in% dataset_ids,
            .data$filetype == "H5AD"
        ) |>
        files_download(dry.run = FALSE)
}

.cxg_as_tibble <-
    function(dataset_ids, local_paths)
{
    db <- db(overwrite = FALSE)
    x <- tibble(dataset_id = dataset_ids, local_path = local_paths)
    left_join(x, datasets(db), by = "dataset_id")
}

.cxg_sce_validate_software_requirements <-
    function()
{
    pkgs <- c("SingleCellExperiment", "zellkonverter", "HDF5Array")
    need <- pkgs[!pkgs %in% rownames(installed.packages())]
    if (length(need)) {
        need <- paste(need, collapse = '", "')
        stop(
            "'cxg(as = \"sce\")' requires additional packages; use\n",
            "    BiocManager::install(c(\"", need, "\"))"
        )
    }
}

.cxg_sce <-
    function(dataset_ids, local_paths)
{
    lapply(local_paths, function(local_path) {
        message("Converting ", basename(local_path))
        zellkonverter::readH5AD(local_path, reader = "R", use_hdf5 = TRUE)
    })
}

##
## ui / server / app
##

.cxg_ui <-
    function()
{
    navbarPage(
        'cellxgenedp',

        tabPanel(
            "Datasets",
            textOutput("datasets_selected", inline = TRUE),
            actionButton("quit_and_download", "Quit and download"),
            actionButton("quit", "Quit"),
            hr(),
            DT::dataTableOutput("datasets")
        ),
        tabPanel(
            "Collections",
            DT::dataTableOutput("collections")
        ),

        id = "navbar"

    )
}

.cxg_server <-
    function(input, output, session)
{
    db <- db(overwrite = FALSE)
    collections <- .cxg_collections(db)
    datasets <- .cxg_datasets(db)
    dataset <- datasets # current dataset(s)
    files <- .cxg_files(db, id = NULL)

    output$datasets_selected <- renderText({
        paste(
            "Datasets selected:",
            length(.cxg_download_cache$ls())
        )
    })

    output$collections <- DT::renderDT({
        .cxg_collections_format(collections)
    }, server = FALSE)

    output$datasets <- DT::renderDT({
        .cxg_datasets_format(dataset)
    }, server = FALSE)

    observeEvent(input$collections_cell_clicked, {
        info <- input$collections_cell_clicked
        if (is.null(info$value))
            return()
        row_idx <- input$collections_row_last_clicked
        id <- collections[row_idx, "collection_id"][[1]]
        dataset <<- datasets |> dplyr::filter(.data$collection_id %in% id)
        output$datasets <- DT::renderDataTable(.cxg_datasets_format(dataset))
        updateNavbarPage(session, 'navbar', selected = 'Datasets')
    })

    observeEvent(input$datasets_cell_clicked, {
        info <- input$datasets_cell_clicked
        if (is.null(info$value))
            return()
        id <- dataset[input$datasets_row_last_clicked, "dataset_id"][[1]]

        if (info$col == 3) {
            files <<- .cxg_files(db, id)
            files |>
                filter(.data$filetype == "CXG") |>
                slice(1) |>
                datasets_visualize()
        }

        ## all selections, including `info$col == 3` toggle download status
        .cxg_download_cache$toggle(id)
        output$datasets_selected <- renderText({
            paste(
                "Datasets selected:",
                length(.cxg_download_cache$ls())
            )
        })
    })

    ## quit

    observeEvent(input$quit_and_download, {
        ids <- .cxg_download_cache$ls()
        stopApp(ids)
    })

    observeEvent(input$quit, {
        stopApp(character(0))
    })
}

#' @name cxg
#' @title Shiny application for discovering, viewing, and downloading
#'     cellxgene data
#'
#' @param as character(1) Return value when quiting the shiny
#'     application. `"tibble"` returns a tibble describing selected
#'     datasets (including the location on disk of the downloaded
#'     file). `"sce"` returns a list of dataset files imported to R as
#'     SingleCellExperiment objects.
#'
#' @return `cxg()` returns either a tibble describing datasets
#'     selected in the shiny application, or a list of datasets
#'     imported into R as SingleCellExperiment objects.
#'
#' @examples
#' \donttest{
#' cxg()
#' }
#'
#' @export
cxg <-
    function(as = c('tibble', 'sce'))
{
    as <- match.arg(as)
    if (identical(as, "sce"))
        .cxg_sce_validate_software_requirements()

    .cxg_download_cache$reset()
    dataset_ids <- runGadget(.cxg_ui(), .cxg_server)
    local_paths <- .cxg_download(dataset_ids, identical(as, "sce"))

    switch(
        as,
        tibble = .cxg_as_tibble(dataset_ids, local_paths),
        sce = .cxg_sce(dataset_ids, local_paths)
    )
}
