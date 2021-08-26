
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

rignore_amend <- function (path = ".") {

    path <- convert_path (path)

    x <- NULL
    rb <- file.path (path, ".Rbuildignore")
    if (file.exists (rb))
        x <- brio::read_lines (rb)

    if (!any (grepl ("^\\^docs(\\/?)", x))) {

        x <- c (x, "^docs/")
        brio::write_lines (x, rb)
    }
}
