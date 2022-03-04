library(shiny)
library(DT)
library(dplyr)

collection_id <- name <- tissue <- assay <- disease <- organism <- cell_count <- 
    dataset_id <- filetype <- NULL

ui <- fluidPage(
    titlePanel('cellxgene data'),

    sidebarLayout(
        sidebarPanel(
            helpText(h4("Number of selected datasets:")), 
            textOutput("rowSum"),
            
            actionButton("quit", "Convert and quit")
        ),

        mainPanel(
            tabsetPanel(
                id = 'tabs',
                tabPanel("Collections", DT::dataTableOutput("collections")),
                tabPanel("Datasets", DT::dataTableOutput("datasets"))
            )
        )
    )
)

.pullLabels <- function(x) {
    labels <- vapply(x, `[[`, character(1), "label")
    paste(labels, collapse = ", ")
}

.shiny_collections <- function(db) {
    collections <- collections(db) |>
        select(c(collection_id, name))

    datasets <- datasets(db) |>
        select(c(collection_id, tissue, assay, disease, organism, cell_count))

    labeledDat <- datasets |>
        dplyr::mutate_at(c("tissue", "assay", "disease", "organism"),
            function(x) vapply(x, .pullLabels, character(1))
        ) |> dplyr::group_by(collection_id) |>
        dplyr::summarise_at(c("tissue", "assay", "disease", "organism"),
            function(x) paste(unique(x), collapse = ", ")
        )

    countDat <- datasets |>
        dplyr::group_by(collection_id) |>
        dplyr::summarise(cell_count = sum(cell_count))

    allDat <- dplyr::left_join(collections, labeledDat, by = "collection_id") |>
        dplyr::left_join(countDat, by = "collection_id")
    allDat
}

.shiny_datasets <- function(db, id) {
    tbl <- datasets(db) |>
        dplyr::select(c(dataset_id, collection_id, name, tissue, assay, disease,
            organism, cell_count)) |>
        dplyr::mutate_at(c("tissue", "assay", "disease", "organism"),
            function(x) vapply(x, .pullLabels, character(1))
        ) |>
        dplyr::mutate(Download = as.character(shiny::icon("cloud-download", lib = "glyphicon"))) |>
        dplyr::mutate(Visualize = as.character(shiny::icon("eye-open", lib = "glyphicon"))) |>
        dplyr::select(c(1, 2, 9, 10, 3, 4, 5, 6, 7, 8))

    if (!is.null(id))
        tbl <- tbl |> dplyr::filter(collection_id == id)
    tbl
}

.shiny_files <- function(db, id) {
    tbl <- files(db)

    if (!is.null(id))
        tbl <- tbl |> dplyr::filter(dataset_id == id)
    tbl
}

.shiny_download_cache <- local({
    files <- new.env(parent = emptyenv())
    list(reset = function() {
        rm(list = ls(files), envir = files)
    }, add = function(id, path) {
        files[[id]] <- path
    }, get = function(id) {
        files[[id]]
    }, as_tibble = function() {
        dataset_id <- ls(files)
        files <- mget(dataset_id, files)
        tibble(
            dataset_id = dataset_id,
            local_path = as.character(unlist(files, use.names = FALSE))
        )}
    )
})

server <- function(input, output, session) {
    db <- db()
    collections <- .shiny_collections(db)
    dataset <- .shiny_datasets(db, id = NULL)
    files <- .shiny_files(db, id = NULL)

    output$rowSum <- renderText({
        length(input$datasets_rows_selected)
    })

    output$collections <- DT::renderDataTable({
        DT::datatable(collections,
            selection = 'single',
            filter = 'top',
            colnames = c('rownames', 'id', 'Collections', 'Tissue', 'Assay', 
                'Disease', 'Organism', 'Cell Count'),
            options = list(
                scrollY = 400,
                columnDefs = list(
                    list(visible = FALSE, targets = c(0,1)),
                    list(width = '110px', targets = c(3,4,5,6,7))
                )
            )
        )
    })

    output$datasets <- DT::renderDataTable({
        DT::datatable(dataset,
            selection = 'single',
            filter = 'top',
            escape = FALSE,
            colnames = c('rownames', 'dat_id', 'col_id', '', '', 'Datasets', 
                'Tissue', 'Assay', 'Disease', 'Organism', 'Cell Count'),
            options = list(
                scrollX = TRUE,
                scrollY = 400,
                autoWidth = TRUE,
                columnDefs = list(
                    list(orderable = FALSE, targets = c(3,4)),
                    list(searchable = FALSE, targets = c(3,4)),
                    list(width = '10px', targets = c(3,4)),
                    list(className = 'dt-center', targets = c(3,4)),
                    list(visible = FALSE, targets = c(0,1,2)),
                    list(width = '110px', targets = c(6,7,8,9,10))
                )
            )
        )
    })

    shiny::observeEvent(input$collections_cell_clicked, {
        info <- input$collections_cell_clicked
        if (is.null(info$value)) return()
        id <- collections[input$collections_row_last_clicked, "collection_id"][[1]]
        dataset <<- .shiny_datasets(db, id)
        output$datasets <- DT::renderDataTable({
            DT::datatable(dataset,
                selection = 'multiple',
                filter = 'top',
                escape = FALSE,
                colnames = c('rownames', 'dat_id', 'col_id', '', '', 'Datasets', 
                    'Tissue', 'Assay', 'Disease', 'Organism', 'Cell Count'),
                options = list(
                    dom = 'ft',
                    scrollY = 400,
                    autoWidth = TRUE,
                    columnDefs = list(
                        list(visible = FALSE, targets = c(0,1,2)),
                        list(width = '10px', targets = c(3,4)),
                        list(width = '110px', targets = c(6,7,8,9,10)),
                        list(className = 'dt-center', targets = c(3,4))
                    )
                )
            )
        })
        shiny::updateTabsetPanel(session, 'tabs', selected = 'Datasets')
    })

    shiny::observeEvent(input$datasets_cell_clicked, {
        info <- input$datasets_cell_clicked
        if (is.null(info$value)) return()
        id <- dataset[input$datasets_row_last_clicked, "dataset_id"][[1]]
        files <<- .shiny_files(db, id)

        if (info$col == 3) {
            .shiny_download_cache$add(id, "")
            
        } else if (info$col == 4) {
            files |>
                dplyr::filter(filetype == "CXG") |>
                dplyr::slice(1) |>
                datasets_visualize()
        } else 
            return()
    })

    #shiny::observe({
    #    if (input$tabs == "stop") {
    #        ids <- .shiny_download_cache$as_tibble()
    #        stopApp(ids)
    #    }
    #})

    shiny::observeEvent(input$quit, {
        ids <- .shiny_download_cache$as_tibble()
        stopApp(ids)
    })
}

.shiny_cxg_as_tibble <- function(x) {
    db <- db()
    left_join(x, datasets(db), by = "dataset_id")
}

.shiny_cxg_list <- function(x) {
    lapply(x$local_path, function(local_path, ...) {
        message("Converting ", basename(local_path))
        zellkonverter::readH5AD(local_path, reader = "R", use_hdf5 = TRUE)
    })
}

.shiny_cxg_download <- function(dataset_ids) {
    message("Downloading ", length(dataset_ids), " files")
    db <- db()
    files(db) |> filter(dataset_id %in% dataset_ids, filetype == "H5AD") |>
        files_download(dry.run = FALSE)
}

shiny_cxg <- function(as = c('tibble', 'list')) {
    as = match.arg(as)
    .shiny_download_cache$reset()

    res <- runGadget(ui, server)
    res$local_path <- .shiny_cxg_download(res$dataset_id)
    switch(as, tibble = .shiny_cxg_as_tibble(res), list = .shiny_cxg_list(res))
}
