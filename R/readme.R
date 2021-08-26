
#' Convert main readme to `readthedocs` file.
#'
#' @return Name of 'README' file in the `docs` folder, after renaming to the
#' package name.
#' @noRd
convert_readme <- function (path = ".") {

    path <- convert_path (path)

    orig <- file.path (path, "README.md")
    if (!file.exists (orig)) {
        msg <- paste0 ("file [", orig, "] not found")
        if (file.exists (file.path (path, "README.Rmd")))
            msg <- paste0 (msg, "\nPlease render README.Rmd -> ",
                           "README.md before proceeding")
        stop (msg)
    }

    dest <- file.path (path, "docs", paste0 (pkg_name (path), ".md"))
    chk <- file.copy (orig, dest, overwrite = TRUE)

    x <- move_hex (brio::read_lines (dest), path)

    pos <- grep ("```eval_rst", x)
    if (length (pos) > 0L) {

        x <- x [1:(pos - 1)]
        hdr <- grep ("^## Functions$", x)
        if (length (hdr) > 0L) {

            x <- x [1:(hdr - 1)]
        }
    }

    x <- c (x,
            "",
            "## Functions",
            "",
            "```eval_rst",
            ".. toctree::",
            "   :maxdepth: 1",
            "")

    fn_files <- list.files (file.path (path, "docs", "functions"),
                            full.names = TRUE,
                            pattern = "\\.md$")
    ptn <- paste0 (.Platform$file.sep, "docs", .Platform$file.sep)
    for (f in fn_files) {

        fn_path <- strsplit (f, ptn) [[1]] [2]
        x <- c (x, paste0 ("   ", fn_path))
    }
    x <- c (x, "```")

    brio::write_lines (x, dest)

    return (dest)
}

#' Separate HTML image from main title
#'
#' Hex (or other) images included in readme titles are also rendered in
#' 'readthedocs' contents table on left panel. This function moves any such
#' images to a separate line so they only appear in the readme docs themselves.
#' @noRd
move_hex <- function (x, path) {

    x <- gsub ("^\\s+$", "", x)
    x <- x [(which (nchar (x) > 0L) [1]):length (x)]

    if (grepl ("<img src", x [1])) {

        src <- strsplit (x [1], "<img src") [[1]] [2]
        fig_src <- regmatches (src, gregexpr ("\'.*\'|\".*\"", src)) [[1]] [1]
        fig_src <- gsub ("\"|\'", "", fig_src)
        fig_src_name <- strsplit (fig_src, .Platform$file.sep) [[1]]
        fig_src_name <- utils::tail (fig_src_name, 1L)
        fig_src_name <- strsplit (fig_src_name, "\\s") [[1]] [1]

        static_dir <- file.path (path, "docs", "_static")
        if (!dir.exists (static_dir))
            dir.create (static_dir, recursive = TRUE)
        dir_dest <- file.path (static_dir, pkg_name (path))
        fig_dest <- file.path (dir_dest, fig_src_name)
        if (!file.exists (fig_dest)) {
            if (!dir.exists (dir_dest))
                dir.create (dir_dest, recursive = TRUE)
            chk <- file.copy (file.path (path, pkg_name (path), fig_src), fig_dest)
        }
        fig_dest <- normalizePath (fig_dest)

        fig_rel <- gsub (file.path (d, "docs"), "", fig_dest)
        fig_rel <- gsub (paste0 ("^", .Platform$file.sep), "", fig_rel)
        tmp <- gsub (fig_src_name, fig_rel, x [1])
        tmp <- strsplit (tmp, "<img src") [[1]]
        x <- c (tmp [1],
                "",
                paste0 ("<img src", tmp [2]),
                x [2:length (x)])
    }

    return (x)
}
