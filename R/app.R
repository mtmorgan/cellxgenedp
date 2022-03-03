library(shiny)
library(DT)
library(dplyr)

collection_id <- name <- tissue <- assay <- disease <- organism <- cell_count <- 
    dataset_id <- filetype <- NULL

ui <- navbarPage(
    title = 'cellxgene data', id = 'tabs',

    tabPanel("Collections", DT::dataTableOutput("collections")),
    tabPanel("Datasets", DT::dataTableOutput("datasets")),
    tabPanel("Quit app", value = "stop", icon = shiny::icon("ban-circle", lib = "glyphicon"))
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
        )
    })
})

server <- function(input, output, session) {
    db <- db()
    collections <- .shiny_collections(db)
    dataset <- .shiny_datasets(db, id = NULL)
    files <- .shiny_files(db, id = NULL)
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
                selection = 'single',
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
            browser()
            local_file <- files |>
                dplyr::filter(filetype == "H5AD") |>
                dplyr::slice(1) |>
                files_download(dry.run = FALSE)
            .shiny_download_cache$add(id, local_file)
            
        } else if (info$col == 4) {
            files |>
                dplyr::filter(filetype == "CXG") |>
                dplyr::slice(1) |>
                datasets_visualize()
        } else 
            return()
    })

    shiny::observe({
        if (input$tabs == "stop") {
            .shiny_download_cache$as_tibble()
            stopApp()
        }
    })
}

shiny_cxg <- function() {
.shiny_download_cache$reset()

shinyApp(ui, server)
}
