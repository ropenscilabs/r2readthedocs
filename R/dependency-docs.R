#' Add documentation of all dependency packages
#' @noRd
add_pkg_deps <- function (path = here::here ()) {

    desc <- data.frame (read.dcf (file.path (path, "DESCRIPTION")))
    imps <- gsub ("\\n", "", strsplit (desc$Imports, ",") [[1]])
    imps <- gsub ("\\s.*$", "", imps)

    if (length (imps) == 0L) {
        return ()
    }

    dep_dir <- normalizePath (
        file.path (path, "docs", "dependencies"),
        mustWork = FALSE
    )
    if (!dir.exists (dep_dir)) {
        dir.create (dep_dir)
    }

    for (i in imps) {

        pkg_dir <- file.path (dep_dir, i)
        if (!dir.exists (pkg_dir)) {
            dir.create (pkg_dir)
        }

        rd <- tools::Rd_db (i)
        vignettes <- add_pkg_to_deps_index_rst (path, i, rd)
        if (nrow (vignettes) > 0L) {
            compile_vignettes (path, i, vignettes)
        }
        add_dep_fns (path, i, rd)
    }

    index <- add_deps_to_main_index_rst (path, imps)
    brio::write_lines (
        index,
        file.path (path, "docs", "index.rst")
    )
}

add_pkg_to_deps_index_rst <- function (path, pkg, rd) {

    nms <- names (rd)

    # Add pkg DESC contents to main index.rst:
    desc <- utils::packageDescription (pkg)
    if ("Authors@R" %in% names (desc)) {
        auts <- eval (parse (text = desc$`Authors@R`))
    } else {
        auts <- desc$Author
    }
    auts <- gsub ("<.*>|\\(.*\\)", "", auts)
    auts <- gsub ("^\\s+|\\s+$", "", auts)
    desc_txt <- gsub ("\\n", "", desc$Description)
    desc_txt <- gsub ("\\s+", " ", desc_txt)

    pkg_index <- c (
        pkg,
        "========",
        "",
        paste0 (".. admonition:: ", desc$Title),
        "",
        paste0 ("    ", desc_txt),
        "",
        paste0 ("Version: ", desc$Version),
        "",
        "Authors:",
        "",
        paste0 ("- ", auts),
        "",
        desc$URL
    )

    # Then add pkg fns toc:
    rd_titles <- tools::file_path_sans_ext (nms)
    pkg_index <- c (
        pkg_index,
        "",
        ".. toctree::",
        "   :maxdepth: 1",
        "   :caption: Functions",
        "",
        paste0 (
            "   ",
            pkg,
            "/",
            rd_titles,
            ".md"
        ),
        ""
    )

    # And vignettes:
    v <- utils::vignette (package = pkg)
    items <- data.frame (v$results)$Item
    v_files <- vapply (items, function (i) {
        v_i <- utils::vignette (i, package = pkg)
        file.path (v_i$Dir, "doc", v_i$File)
    }, character (1))
    v$results <- v$results [grep ("\\.Rmd$", v_files), ]
    if (is.null (dim (v$results))) {
        v$results <- t (v$results)
    }

    if (nrow (v$results) > 0L) {
        pkg_index <- c (
            pkg_index,
            ".. toctree::",
            "   :maxdepth: 1",
            "   :caption: Vignettes",
            "",
            paste0 (
                "   ",
                pkg,
                "/",
                data.frame (v$results)$Item,
                ".md"
            ),
            ""
        )
    }

    dep_dir <- file.path (path, "docs", "dependencies")
    index_file <- file.path (dep_dir, "index.rst")
    index_contents <- NULL
    if (file.exists (index_file)) {
        index_contents <- c (
            brio::read_lines (index_file),
            "",
            "-----",
            ""
        )
    }
    brio::write_lines (
        c (index_contents, pkg_index),
        index_file
    )

    return (data.frame (v$results))
}

compile_vignettes <- function (path, pkg, vignettes) {

    fmt <- rmarkdown::md_document (variant = "gfm")
    titles <- gsub ("\\s\\(source,\\shtml\\)", "", vignettes$Title)

    for (i in seq_len (nrow (vignettes))) {

        v_file <- file.path (
            vignettes$LibPath [i],
            vignettes$Package [i],
            "doc",
            paste0 (vignettes$Item [i], ".Rmd")
        )
        if (!file.exists (v_file)) {
            next
        }

        ftmp <- file.path (tempdir (), basename (v_file))
        file.copy (v_file, ftmp)

        # bibliography files are not retained in installed pkgs, causing pandoc
        # to fail. Work-around is to simply remove the bib line, rendering
        # vignette without references.
        v_i <- brio::read_lines (ftmp)
        bib_line <- grep ("^bibliography\\:", v_i)
        if (length (bib_line) > 0L) {
            v_i <- v_i [-bib_line]
            brio::write_lines (v_i, ftmp)
        }

        f_md <- tryCatch (
            rmarkdown::render (ftmp,
                output_format = fmt,
                envir = new.env (),
                quiet = TRUE
            ),
            error = function (e) NULL
        )

        file.remove (ftmp)

        if (is.null (f_md)) {
            next
        }

        contents <- c (
            paste0 ("# ", titles [i]),
            "",
            brio::read_lines (f_md)
        )
        f_md_here <- file.path (
            path,
            "docs",
            "dependencies",
            pkg,
            basename (f_md)
        )
        brio::write_lines (contents, f_md_here)

        file.remove (f_md)
    }
}

add_deps_to_main_index_rst <- function (path, dep_pkgs) {

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

    c (
        index,
        "",
        ".. toctree::",
        "   :maxdepth: 1",
        "   :caption: Dependencies",
        "",
        "   dependencies/index",
        "",
        end_txt
    )
}


#' Add functions for one dependency package
#' @noRd
add_dep_fns <- function (path, pkg, rd) {

    fout <- tempfile (fileext = ".md")
    dep_dir <- normalizePath (file.path (path, "docs", "dependencies"),
        mustWork = FALSE
    )
    pkg_dir <- file.path (dep_dir, pkg)

    for (n in names (rd)) {

        out <- NULL # rm unused variable note
        out <- Rd2md::Rd2markdown (rd [[n]], outfile = fout)
        md <- brio::read_lines (fout)

        # insert MyST link target:
        md <- c (
            paste0 ("(", pkg, "_", n, ")="),
            "",
            md
        )

        mdout <- file.path (
            pkg_dir,
            paste0 (
                tools::file_path_sans_ext (n),
                ".md"
            )
        )

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
