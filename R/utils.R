
convert_path <- function (path = ".") {

    if (path == ".")
        path <- here::here ()
    path <- normalizePath (path)

    return (path)
}

pkg_name <- function (path = ".") {

    path <- convert_path (path)

    d <- file.path (path, "DESCRIPTION")
    if (!file.exists (d))
        stop ("'DESCRIPTION' file not found")
    d <- read.dcf (d)
    return (unname (d [1, "Package"]))
}

pkg_authors <- function (path = ".") {

    path <- convert_path (path)
    d <- file.path (path, "DESCRIPTION")
    if (!file.exists (d))
        stop ("'DESCRIPTION' file not found")

    aut <- desc::desc_get_authors (path)
    roles <- regmatches (aut, gregexpr ("\\[.*\\]", aut))
    aut <- aut [grep ("aut", roles)]
    aut <- gsub ("\\[.*\\]|<.*>", "", aut)
    aut <- gsub ("^\\s+|\\s+$", "", aut)

    return (aut)
}

rignore_amend <- function (path = ".") {

    path <- convert_path (path)

    x <- NULL
    rb <- file.path (path, ".Rbuildignore")
    if (file.exists (rb))
        x <- brio::read_lines (rb)

    update <- FALSE
    if (!any (grepl ("^\\^docs(\\/?)", x))) {
        update <- TRUE
        x <- c (x, "^docs/")
    }
    if (!any (grepl ("readthedocs\\.yaml", x))) {
        update <- TRUE
        x <- c (x, "^\\.readthedocs.yaml")
    }

    if (update)
        brio::write_lines (x, rb)
}
