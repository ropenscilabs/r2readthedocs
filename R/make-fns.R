# fns from RTD `make` commands

#' Build the RTD site
#'
#' @inheritParams r2readthedocs
#' @export
rtd_build <- function (path = ".", dev = FALSE) {

    docs_path <- file.path (convert_path (path), "docs")
    if (!file.exists (docs_path))
        stop ("path must have a 'docs' directory; ",
              "try running 'r2readthedocs' first")

    if (dev) {
        rm_pkg_deps (path) # to enable clean updates
        add_pkg_deps (path)
    } else if (dir.exists (file.path (docs_path, "dependencies"))) {
        rm_pkg_deps (path)
    }

    withr::with_dir (docs_path,
                     system2 ("make", "html"))
}


#' Clean the RTD `_build` directory
#'
#' @inheritParams r2readthedocs
#' @param full If `TRUE`, also clean R package files, including vignettes and
#' help files. Use \link{r2readthedocs} to re-generate these.
#' @export
rtd_clean <- function (path = ".", full = FALSE) {

    path <- convert_path (path)
    path_docs <- file.path (path, "docs")

    ret <- NULL

    if (dir.exists (path_docs)) {

        ret <- withr::with_dir (path_docs,
                                system2 ("make", args = "clean"))

        if (full) {

            dirs <- list.dirs (path_docs, recursive = FALSE)
            dirs <- dirs [which (!grepl ("\\_build$", dirs))]

            # match to man and vignettes directories
            r_dirs <- c ("man", "vignettes")
            r_files <- lapply (r_dirs, function (i)
                               list.files (file.path (path, i),
                                           recursive = TRUE))
            r_files <- grep ("\\.Rd$|\\.Rmd$|\\.md$",
                             unlist (r_files),
                             value = TRUE)
            r_files <- vapply (strsplit (r_files, "\\."),
                               function (i) i [1L],
                               character (1))
            r_files <- paste0 (r_files, collapse = "|")

            # Then only unlink corresponding auto-generated dirs, while
            # retaining all others
            for (d in dirs) {
                if (all (grep (r_files, list.files (d))))
                    chk <- unlink (d, recursive = TRUE)
            }
        }
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
