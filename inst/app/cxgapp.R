#' @importFrom zellkonverter readH5AD
#' @export
browse_cxg = function() {
  library(shiny)
  library(cellxgenedp)
  library(jsonlite)
  library(zellkonverter)
  library(DT)
  db = try(db())
  if (inherits(db, "try-error")) stop("can't get db")
  
  jsdb = fromJSON(db)  # is character, makes data.frame!
  nn = jsdb$name
  names(nn) = paste(seq_len(nrow(jsdb)), nn)
  
  colls = collections(db)
  cname = colls$name
  names(cname) = colls$collection_id
  
  ds = datasets(db)
  sds = split(ds, ds$collection_id)
  names(sds) = cname[names(sds)] 
  nn = names(sds)
  names(nn) = paste(seq_len(nrow(jsdb)), nn)
  accumDSIDS <<- NULL
  
  ui = fluidPage(
   sidebarLayout(
    sidebarPanel(
     helpText("cellxgene data portal browser for AnVIL"),
     selectInput("coll", "collections", choices=nn),
     selectInput("keep", "cart", choices = ds$dataset_id, multiple=TRUE),
    actionButton("convert", "convert&stop")
     ),
    mainPanel(
     DT::dataTableOutput("curdat")
    )
   )
  )
  
  server = function(input, output, session) {
   output$curdat = DT::renderDataTable({
     tab0 = sds[[input$coll]]
     isl = sapply(tab0, is.list)
     tab1 = tab0[,-which(isl)]
     tab1 = tab1[, c("name", "collection_visibility", "cell_count")]
     tab2 = tab1
     assay = sapply(tab0$assay[[1]], "[", "label")
     ds_id = tab0$dataset_id
     cbind(tab2, assay=as.character(assay), dataset=as.character(ds_id))
   })
   observeEvent(input$curdat_rows_selected, {
     accumDSIDS <<- unique(c(accumDSIDS, sds[[input$coll]][ input$curdat_rows_selected, "dataset_id" ][[1]]))
     print(accumDSIDS)
     updateSelectInput(session, "keep",  selected=accumDSIDS)
    })
   observeEvent(input$convert, {
     fi = files(db) |> dplyr::filter(dataset_id %in% accumDSIDS, filetype=="H5AD") |> files_download(dry.run=FALSE)
     validate(need(nrow(fi)>0, "must have at least one dataset selected"))
     ans = lapply(seq_len(length(fi)), function(i) readH5AD(fi[[i]], reader = "R", use_hdf5 = TRUE))
     stopApp(ans)
     })
     
  }
  
  runApp(list(ui=ui, server=server))
}
