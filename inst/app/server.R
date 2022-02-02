
# setup

  db = try(cellxgenedp::db())
  if (inherits(db, "try-error")) stop("can't get db")

  accumDSIDS <<- ""   # manage selected files
 
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

  server = function(input, output, session) {
#
# naive report
#
   output$dbdump = renderPrint( db )
#
# slimmed table of features of all datasets within a collection
#
   output$curdat = DT::renderDT({   # lists within data.frame are not well-handled by datatable()
     tab0 = sds[[input$coll]]
     isl = sapply(tab0, is.list)
     tab1 = tab0[,-which(isl)]
     tab1 = tab1[, c("name", "collection_visibility", "cell_count")]
     tab2 = tab1
     assay = sapply(tab0$assay[[1]], "[", "label")
     ds_id = tab0$dataset_id
     cbind(tab2, assay=as.character(assay), dataset=as.character(ds_id))
   })
#
# build up selections
#
   observeEvent(input$curdat_rows_selected, {
     inds = input$curdat_rows_selected
     print(inds)
     if (length(inds) == 0) {
          accumDSIDS <<- ""
          }
     else accumDSIDS <<- sds[[input$coll]][ input$curdat_rows_selected, "dataset_id" ][[1]]
     updateSelectInput(session, "keep",  selected=accumDSIDS)
    }, ignoreNULL=FALSE)  # crucial!
#
# return a list of converted H5AD on request, and shutdown
#
   observeEvent(input$convert, {
     fi = cellxgenedp::files(db) |> dplyr::filter(dataset_id %in% accumDSIDS, filetype=="H5AD") |> cellxgenedp::files_download(dry.run=FALSE)
     validate(need(nrow(fi)>0, "must have at least one dataset selected"))
     ans = lapply(seq_len(length(fi)), function(i) zellkonverter::readH5AD(fi[[i]], reader = "R", use_hdf5 = TRUE))
     stopApp(ans)
     })
#
# clear all selections -- could be more nuanced
#
   observeEvent(input$clearcart, {
     accumDSIDS <<- NULL
     updateSelectInput(session, "keep",  selected="")
     })
  }
