
#' Convert all files in `man` directory to markdown files
#'
#' The converted `.md` files are placed in `./docs/functions`. Index entries for
#' these are added in the `convert_readme()` function.
#' @return Nothing
#' @noRd
convert_man <- function (path = ".") {

    path <- convert_path (path)

    docs <- file.path (path, "docs")
    fns_dir <- file.path (docs, "functions")
    if (!dir.exists (fns_dir))
        chk <- dir.create (fns_dir, recursive = TRUE)

    flist <- list.files (file.path (path, "man"),
                         full.names = TRUE,
                         pattern = "\\.Rd$")

    for (f in flist) {

        fshort <- utils::tail (strsplit (f, .Platform$file.sep) [[1]], 1L)
        fout <- file.path (fns_dir, gsub ("\\.Rd$", ".md", fshort))
        Rd2md::Rd2markdown (f, outfile = fout)
    }
}
