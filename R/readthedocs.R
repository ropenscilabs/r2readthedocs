#' Convert package documentation to `readthedocs` format
#'
#' @param path Path to local R package with documentation to be converted
#' @return TRUE (invisibly) if documentation successfully converted.
#' @export
r2readthedocs <- function (path) {

    path <- convert_path (path)

    readthedocs_yaml (path)

    exdir <- system.file ("extdata", package = "r2readthedocs")
    flist <- list.files (exdir, full.names = TRUE)
    flist <- flist [-grep ("readthedocs\\.yaml$", flist)]
    flist <- gsub (exdir, "", flist)
    flist <- gsub (paste0 ("^", .Platform$file.sep), "", flist)

    for (f in flist) {

        readthedocs_file (path, f)
    }

    convert_man (path)
    convert_readme (path)
    convert_vignettes (path)
    rignore_amend (path)

    extend_index_rst (path)

    invisible (TRUE)
}

extend_index_rst <- function (path) {

    index <- file.path (path, "docs", "index.rst")
    if (!file.exists (index))
        stop ("File [", index, "] not found")

    x <- c (brio::read_lines (index),
            "",
            "   demo",
            "",
            "",
            add_index_section (path, "vignettes"),
            add_index_section (path, "functions"))

    brio::write_lines (x, index)
}

add_index_section <- function (path, type = "functions") {

    the_dir <- file.path (path, "docs", type)
    if (!dir.exists (the_dir))
        return (NULL)

    type_cap <- type
    substring (type_cap, 1, 1) <- toupper (substring (type_cap, 1, 1))

    x <- c ("",
            "",
            ".. toctree::",
            "   :maxdepth: 1",
            paste0 ("   :caption: ", type_cap),
            "")

    for (f in list.files (the_dir)) {

        x <- c (x,
                paste0 ("   ", type, .Platform$file.sep, f))
    }

    return (x)
}
