#' Convert package documentation to `readthedocs` format
#'
#' @param path Path to local R package with documentation to be converted
#' @return TRUE (invisibly) if documentation successfully converted.
#' @export
readthedocs <- function (path) {

    path <- convert_path (path)

    convert_man (path)
    convert_readme (path)
    convert_vignettes (path)
    rignore_amend (path)

    readthedocs_yaml (path)

    exdir <- system.file ("extdata", package = "r2readthedocs")
    flist <- list.files (exdir, full.names = TRUE)
    flist <- flist [-grep ("readthedocs\\.yaml$", flist)]
    flist <- gsub (exdir, "", flist)
    flist <- gsub (paste0 ("^", .Platform$file.sep), "", flist)

    for (f in flist) {

        readthedocs_file (path, f)
    }

    invisible (TRUE)
}
