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

#' @importFrom utils installed.packages
.cxg_sce_validate_software_requirements <-
    function()
{
    pkgs <- c("SingleCellExperiment", "zellkonverter", "HDF5Array")
    need <- setdiff(pkgs, rownames(installed.packages()))
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

#' @importFrom miniUI miniPage gadgetTitleBar miniContentPanel
.cxg_datasets_app <-
    function()
{
    miniPage(
        gadgetTitleBar("Cellxgene Datasets"),
        miniContentPanel({
            DT::dataTableOutput("datasets")
        })
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

.cxg_labels <-
    function(x)
{
    vapply(x, function(elt) {
        labels <- vapply(elt, `[[`, character(1), "label")
        paste(labels, collapse = ", ")
    }, character(1))
}

.cxg_dataset_format <-
    function(db)
{
    all_datasets <- datasets(db)
    
    all_datasets |> 
        mutate(across(c("organism", "tissue", "disease", "assay", "cell_type",
                        "development_stage", "ethnicity", "sex"), .cxg_labels),
               view = as.character(shiny::icon("eye-open", lib = "glyphicon"))) |>
        select("collection_id", "dataset_id", "view", "name", "organism",
               "tissue", "disease", "assay", "cell_count", "cell_type",
               "development_stage", "ethnicity", "mean_genes_per_cell", "sex")
}

#' @importFrom shiny runGadget observeEvent stopApp
#'
#' @importFrom DT renderDataTable datatable dataTableOutput formatStyle
.cxg_datasets_server <-
    function()
{
    db <- db(overwrite=FALSE)
    tbl <- .cxg_dataset_format(db)
    function(input, output) {
        output$datasets = DT::renderDataTable({
            DT::datatable(
                tbl,
                selection = 'none',
                escape = FALSE,
                extensions = c('Buttons','Select'),
                rownames = FALSE,
                options = list(
                    scrollY = TRUE,
                    scrollX = TRUE,
                    pageLength = 100,
                    dom = "Blfrtip",
                    select = list(style = "multi", items = "row"),
                    buttons = list(list(extend='selectAll',className='selectAll',
                                        text="Select All",
                                        action=DT::JS("function () {
                                var table = $('.dataTable').DataTable();
                                table.rows({ search: 'applied'}).deselect();
                                table.rows({ search: 'applied'}).select();
                }")
                    ), list(extend='selectNone',
                            text="Deselect All",
                            action=DT::JS("function () {
                                var table = $('.dataTable').DataTable();
                                table.rows({ search: 'applied'}).select();
                                table.rows({ search: 'applied'}).deselect();
                }")
                    ))
                )
            ) |>
            formatStyle(colnames(tbl), 'vertical-align' = "top")
        }, server = FALSE)

        observeEvent(input$datasets_cell_clicked, {
            info <- input$datasets_cell_clicked
            if (is.null(info$value))
                return()
            id <- tbl[input$datasets_cell_clicked$row, "dataset_id"][[1]]

            if (info$col == 2) {
                fls <<- .cxg_files(db, id)
                fls |>
                    filter(.data$filetype == "CXG") |>
                    slice(1) |>
                    datasets_visualize()
            }
        })

        observeEvent(input$done, {
            ids <- tbl[input$datasets_rows_selected, "dataset_id"][[1]]
            stopApp(ids)
        })
    }
}

#' @rdname cxg_datasets
#'
#' @title View and select datasets interactively
#'
#' @return `cxg_datasets()` returns a tibble with download locations of selected
#'     datasets in the interface.
#'
#' @examples
#' if (interactive()) {
#'     cxg_datasets()
#' }
#' @export
cxg_datasets <-
    function(as = c('tibble', 'sce'))
{
    as <- match.arg(as)
    if (identical(as, "sce"))
        .cxg_sce_validate_software_requirements()

    .cxg_download_cache$reset()
    dataset_ids <- runGadget(app = .cxg_datasets_app(), server = .cxg_datasets_server())
    local_paths <- .cxg_download(dataset_ids, identical(as, "sce"))

    switch(
        as,
        tibble = .cxg_as_tibble(dataset_ids, local_paths),
        sce = .cxg_sce(dataset_ids, local_paths)
    )
}
