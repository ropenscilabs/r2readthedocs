
#' Convert all files in `vignette` directory to markdown files in `docs`
#'
#' The converted `.md` files are placed in `./docs/vignettes`, along with an
#' index file for this directory.
#' @return Nothing
#' @noRd
convert_vignettes <- function (path = ".") {

    path <- convert_path (path)

    docs <- file.path (path, "docs")
    v_dir <- file.path (docs, "vignettes")
    if (!dir.exists (v_dir))
        chk <- dir.create (v_dir, recursive = TRUE)

    flist <- list.files (file.path (path, "vignettes"),
                         full.names = TRUE,
                         pattern = "\\.Rmd$")

    for (f in flist) {

        f_md <- gsub ("\\.Rmd$", ".md", f)
        if (!file.exists (f_md)) {

            message ("markdown-rendered version [", f_md,
                     "] does not exist\nThis will now be rendered.")
            requireNamespace ("rmarkdown")
            fmt <- rmarkdown::md_document (variant = "gfm")
            rmarkdown::render (f, output_format = fmt, output_file = f_md)
        }

        f_short <- utils::tail (strsplit (f_md, .Platform$file.sep) [[1]], 1L)
        dest <- file.path (v_dir, f_short)
        file.copy (f_md, dest)
    }
}
