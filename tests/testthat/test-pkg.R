
source ("../pkg-skeleton.R")

test_that("dummy package", {

              pkg_name <- paste0 (sample (c (letters, LETTERS), size = 8),
                                  collapse = "")
              d <- make_dummy_pkg (pkg_name = pkg_name)
              expect_true (dir.exists (d))

              expect_false (dir.exists (file.path (d, "docs")))

              expect_silent (convert_man (d))
              expect_true (dir.exists (file.path (d, "docs")))
              expect_true (dir.exists (file.path (d, "docs", "functions")))

              flist <- list.files (file.path (d, "docs"))
              expect_false (any (grepl ("\\.md$", flist))) # no readme.md (-> random.md)

              expect_silent (convert_readme (d))
              flist <- list.files (file.path (d, "docs"))
              expect_true (any (grepl ("\\.md$", flist)))

              unlink (d, recursive = TRUE)
})
