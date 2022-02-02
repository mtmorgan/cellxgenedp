  library(shiny)
  library(cellxgenedp)
  library(jsonlite)
  library(zellkonverter)
  library(DT)

#  db = try(cellxgenedp::db())
#  if (inherits(db, "try-error")) stop("can't get db")
#  
#  jsdb = fromJSON(db)  # is character, makes data.frame!
#  nn = jsdb$name
#  names(nn) = paste(seq_len(nrow(jsdb)), nn)
#  
#  colls = cellxgenedp::collections(db)
#  cname = colls$name
#  names(cname) = colls$collection_id
#  
#  ds = cellxgenedp::datasets(db)
#  sds = split(ds, ds$collection_id)
#  names(sds) = cname[names(sds)] 
#  nn = names(sds)
##  names(nn) = paste(seq_len(nrow(jsdb)), nn)
#  names(nn) = paste0(nn, " (", vapply(sds,nrow,integer(1)), ")")
#  

# setup

  db = try(cellxgenedp::db())
  if (inherits(db, "try-error")) stop("can't get db")

  accumDSIDS <<- NULL   # manage selected files
 
#
# build the named vector to drive selectInput
#
#  jsdb = jsonlite::fromJSON(db)  # is character, makes data.frame!
#  nn = jsdb$name
#  names(nn) = paste(seq_len(nrow(jsdb)), nn)
 
#
# collection names processing
#
  colls = collections(db)
  cname = colls$name
  names(cname) = colls$collection_id
 

#
# build the named vector to drive selectInput
#
  ds = datasets(db)
  sds = split(ds, ds$collection_id)
  names(sds) = cname[names(sds)]
  nn = names(sds)
  names(nn) = paste0(nn, " (", vapply(sds,nrow,integer(1)), ")")


  ui = fluidPage(
   sidebarLayout(
    sidebarPanel(
     helpText(h3("Browse and import data from the cellxgene data portal")),
     verbatimTextOutput("dbdump"),
     selectInput("coll", "collections (# of datasets)", choices=nn),
     selectInput("keep", "cart", choices = ds$dataset_id, multiple=TRUE),
     actionButton("clearcart", "clear cart"),
     actionButton("convert", "convert & stop")
     ),
    mainPanel(
     helpText(h4("Click on table row to add dataset request to cart.  If H5AD representations
are available, they will be converted to SingleCellExperiments with HDF5 backing,
cached, and returned as a list.")),
     DT::dataTableOutput("curdat")
    )
   )
  )
  
