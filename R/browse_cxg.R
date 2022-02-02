#' simple shiny browser that works with the portal `db` components
#' to present titles of collections and datasets and facilitate
#' selection and conversion of cellxgene resources
#' @import shiny
#' @importFrom zellkonverter readH5AD
#' @importFrom DT renderDataTable dataTableOutput
#' @return list, possibly empty, of SingleCellExperiment instances, obtained on 
#' interactive selections using `files_download()`
#' @examples
#' if (interactive()) sel = browse_cxg()
#' @export
browse_cxg = function() {
 curd = getwd()
 on.exit(setwd(curd))
 setwd(system.file("app", package="cellxgenedp"))
 shiny::runApp()
}
