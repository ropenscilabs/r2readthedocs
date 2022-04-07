
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

    for (i in imps) {

        pkg_dir <- file.path (dep_dir, i)
        if (!dir.exists (pkg_dir)) {
            dir.create (pkg_dir)
        }
        rd <- tools::Rd_db (i)
        nms <- names (rd)

        # add pkg toc to main index.rst:
        rd_titles <- tools::file_path_sans_ext (nms)
        pkg_index <- c (
                        i,
                        "==========",
                        "",
                        ".. toctree::",
                        "   :maxdepth: 1",
                        "   :caption: Functions",
                        "",
                        paste0 ("   ",
                                i,
                                "/",
                                rd_titles,
                                ".md"),
                        ""
        )

        index_file <- file.path (dep_dir, "index.rst")
        index_contents <- NULL
        if (file.exists (index_file)) {
            index_contents <- c (brio::read_lines (index_file),
                                 "",
                                 "-----",
                                 "")
        }
        brio::write_lines (c (index_contents, pkg_index),
                           index_file)

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

    c (index,
       "",
       ".. toctree::",
       "   :maxdepth: 1",
       "   :caption: Dependencies",
       "",
       "   dependencies/index",
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
        out <- NULL # rm unused variable note
        md <- brio::read_lines (fout)
        #md <- gsub ("^\\#\\#\\#\\s", "#### ", md)
        #md <- gsub ("^\\#\\#\\s", "### ", md)
        #md <- gsub ("^\\#\\s", "## ", md)

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

#' Remove documentation of dependency packages
#' @noRd
rm_pkg_deps <- function (path = here::here ()) {

    dep_dir <- file.path (path, "docs", "dependencies")
    if (!dir.exists (dep_dir)) {
        return ()
    }

    unlink (dep_dir, recursive = TRUE)
    
    f <- file.path (path, "docs", "index.rst")
    if (!file.exists (f)) {
        return ()
    }
    index <- brio::read_lines (f)

    toc <- grep ("^\\.\\.\\stoctree\\:\\:$", index)
    deps_index <- grep ("^\\s+dependencies\\/", index)
    if (length (deps_index) == 0L) {
        return ()
    }
    toc <- max (toc [which (toc < min (deps_index))])

    index <- index [-seq (toc, max (deps_index))]

    brio::write_lines (index, f)
}
