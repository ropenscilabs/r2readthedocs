
#' Move `.readthedocs.yaml` file to local root folder.
#'
#' This needs a separate function because this file is copied to the root,
#' rather than `docs` folder, and also because it is a dot-file, yet can only be
#' included in an R package without the dot prefix.
#' @noRd
readthedocs_yaml <- function (path = ".") {

    path <- convert_path (path)

    f <- system.file ("extdata", "readthedocs.yaml",
                      package = "r2readthedocs",
                      mustWork = TRUE)

    out <- file.path (path, ".readthedocs.yaml")
    file.copy (f, out)

    return (out)
}

#' Copy one `readthedocs` file from `inst/extdata` into installation path.
#' @noRd
readthedocs_file <- function (path = ".", filename = NULL) {

    if (is.null (filename))
        stop ("filename must be specified")

    path <- file.path (path, "docs")
    if (!dir.exists (path))
        dir.create (path, recursive = TRUE)

    f <- system.file ("extdata", filename,
                      package = "r2readthedocs",
                      mustWork = TRUE)

    out <- file.path (path, filename)
    file.copy (f, out)

    return (out)
}
