
#' Add documentation of all dependency packages
#' @noRd
add_pkg_deps <- function (path = here::here ()) {

    desc <- data.frame (read.dcf (file.path (path, "DESCRIPTION")))
    imps <- gsub ("\\n", "", strsplit (desc$Imports, ",") [[1]])

    dep_dir <- normalizePath (file.path (path, "docs", "dependencies"),
                              mustWork = FALSE)
    if (!dir.exists (dep_dir)) {
        dir.create (dep_dir)
    }
    fout <- tempfile (fileext = ".md")
    for (i in imps) {
        pkg_dir <- file.path (dep_dir, i)
        if (!dir.exists (pkg_dir)) {
            dir.create (pkg_dir)
        }
        rd <- tools::Rd_db (i)
        nms <- names (rd)

        # make index for that pkg:
        rd_titles <- tools::file_path_sans_ext (nms)
        pkg_index <- c (
                        paste0 ("# ", i),
                        "",
                        paste0 ("- [",
                                rd_titles,
                                "](",
                                paste0 (i, "_", nms),
                                ")")
        )

        brio::write_lines (pkg_index,
                           file.path (dep_dir, paste0 (i, ".md")))

        add_dep_fns (path, i, rd)
    }

    index <- add_deps_to_index_rst (path, imps)
    brio::write_lines (index,
                       file.path (path, "docs", "index.rst"))
}

add_deps_to_index_rst <- function (path, dep_pkgs) {

    f <- file.path (path, "docs", "index.rst")
    if (!file.exists (f)) {
        stop ("file [", f, "] does not exist")
    }

    index <- brio::read_lines (f)
    deps <- grep ("^\\s+dependencies\\/", index)

    if (length (deps) > 0L) {

        toc <- grep ("^\\.\\.\\stoctree\\:\\:$", index)
        toc <- toc [max (which (toc < min (deps)))]
        deps_index <- seq (toc, max (deps))
        index <- index [-deps_index]
    }

    # remove any text at the end of toctree items, to be replaced later:
    toc <- grep ("^\\.\\.\\stoctree\\:\\:$", index)
    txtlines <- grep ("^\\w", index)
    txtlines <- txtlines [which (txtlines > max (toc))]
    end_txt <- NULL

    if (length (txtlines) > 0L) {
        index_end <- seq (min (txtlines), length (index))
        end_txt <- index [index_end]
        index <- index [-index_end]
    }

    index <- c (index,
                "",
                ".. toctree::",
                "   :maxdepth: 1",
                "   :caption: Dependencies",
                "")
    for (d in dep_pkgs) {
        index <- c (index,
                    paste0 ("   dependencies/", d, ".md"))
    }

    c (index,
       "",
       end_txt)
}


#' Add functions for one dependency package
#' @noRd
add_dep_fns <- function (path, pkg, rd) {

    fout <- tempfile (fileext = ".md")
    dep_dir <- normalizePath (file.path (path, "docs", "dependencies"),
                              mustWork = FALSE)
    pkg_dir <- file.path (dep_dir, pkg)

    for (n in names (rd)) {

        out <- Rd2md::Rd2markdown (rd [[n]], outfile = fout)
        md <- brio::read_lines (fout)
        md <- gsub ("^\\#\\#\\#\\s", "#### ", md)
        md <- gsub ("^\\#\\#\\s", "### ", md)
        md <- gsub ("^\\#\\s", "## ", md)

        # insert MyST link target:
        md <- c (paste0 ("(", pkg, "_", n, ")="),
                 "",
                 md)

        mdout <- file.path (pkg_dir,
                            paste0 (tools::file_path_sans_ext (n),
                                    ".md"))

        # finally, remove local markdown hyperlinks automatically inserted by
        # `Rd2md`:
        g <- gregexpr ("\\[.*\\]\\(.*\\)", md)
        links <- unique (unlist (regmatches (md, g)))
        link_content <- gsub ("^\\[|\\]\\(.*$", "", links)
        for (l in seq_along (links)) {
            md <- gsub (links [l], link_content [l], md, fixed = TRUE)
        }

        brio::write_lines (md, mdout)
    }

    file.remove (fout)
}