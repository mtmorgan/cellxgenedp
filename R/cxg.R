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
        select(c("collection_id", "name"))

    datasets <-
        datasets(db) |>
        select(
            "collection_id", "tissue", "assay", "disease", "organism",
            "cell_count"
        )

    labeledDat <-
        datasets |>
        mutate(
            across(c("tissue", "assay", "disease", "organism"), .cxg_labels)
        ) |>
        group_by(.data$collection_id) |>
        summarize(across(
            c("tissue", "assay", "disease", "organism"),
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
    datasets(db) |>
        mutate(
            across(c("tissue", "assay", "disease", "organism"), .cxg_labels),
            view = as.character(icon("eye-open", lib = "glyphicon"))
        ) |>
        select(
            "dataset_id", "collection_id", "view", "name", "tissue", "assay",
            "disease", "organism", "cell_count"
        )
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
    dt <- datatable(
        tbl,
        selection = 'single',
        filter = 'top',
        colnames = c(
            'rownames', 'id', 'Collection', 'Tissue', 'Assay',
            'Disease', 'Organism', 'Cells'
        ),
        options = list(
            scrollY = 400,
            columnDefs = list(
                list(visible = FALSE, targets = 0:1),
                list(width = '20px', targets = 4:7)
            )
        )
    )
    formatStyle(dt, 2:7, 'vertical-align' = 'top')
}

.cxg_datasets_format <-
    function(tbl)
{
    dt <- datatable(
        tbl,
        selection = 'multiple',
        filter = 'top',
        escape = FALSE,
        colnames = c(
            'rownames', 'dataset_id', 'collection_id', 'View', 'Dataset',
            'Tissue', 'Assay', 'Disease', 'Organism',
            'Cells'
        ),
        options = list(
            scrollX = TRUE,
            scrollY = 400,
            columnDefs = list(
                list(visible = FALSE, targets = 0:2),
                list(className = 'dt-center', width = "10px", targets = 3)
            )
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

    output$collections <- DT::renderDataTable({
        .cxg_collections_format(collections)
    })

    output$datasets <- DT::renderDataTable({
        .cxg_datasets_format(dataset)
    })

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
