# fns from RTD `make` commands

#' Build the RTD site
#'
#' @inheritParams r2readthedocs
#' @export
rtd_build <- function (path = ".") {

    path <- file.path (convert_path (path), "docs")
    if (!file.exists (path))
        stop ("path must have a 'docs' directory; try running 'r2readthedocs' first")

    withr::with_dir (path,
                     system2 ("make", "html"))
}


#' Clean the RTD `_build` directory
#'
#' @inheritParams r2readthedocs
#' @export
rtd_clean <- function (path = ".") {

    path <- convert_path (path)
    path_build <- file.path (path, "docs", "_build")

    ret <- NULL

    if (dir.exists (path_build)) {

        ret <- withr::with_dir (path_build,
                                system2 ("make", args = "clean"))
    }

    invisible (ret)
}

#' Open the main RTD 'html' page in default browser
#'
#' @inheritParams r2readthedocs
#' @export
rtd_open <- function (path = ".") {

    path <- convert_path (path)

    path_html <- file.path (path, "docs", "_build", "html")

    if (!dir.exists (path_html))
        stop ("html pages do not exist; try running 'rtd_build' first")

    withr::with_dir (path_html,
                     utils::browseURL ("index.html"))
}
