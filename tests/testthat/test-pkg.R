
test_all <- (identical (Sys.getenv ("MPADGE_LOCAL"), "true") |
    identical (Sys.getenv ("GITHUB_WORKFLOW"), "test-coverage"))

skip_on_os ("windows") # pandoc < required version

# explicit steps through each sub-fn of main r2readthedocs() fn:
test_that("readthedocs sub-functions", {

              pkg_name <- paste0 (sample (c (letters, LETTERS), size = 8),
                                  collapse = "")
              path <- rtd_dummy_pkg (pkg_name = pkg_name)
              expect_true (dir.exists (path))

              expect_false (dir.exists (file.path (path, "docs")))

              rb <- file.path (path, ".Rbuildignore")
              expect_false (file.exists (rb))
              rignore_amend (path)
              expect_true (file.exists (rb))

              expect_false (dir.exists (file.path (path, "docs")))

              expect_silent (convert_man (path))
              expect_true (dir.exists (file.path (path, "docs")))
              expect_true (dir.exists (file.path (path, "docs", "functions")))

              flist <- list.files (file.path (path, "docs"))
              # no readme.md (-> random.md):
              expect_false (any (grepl ("\\.md$", flist)))

              expect_silent (r <- convert_readme (path))
              flist <- list.files (file.path (path, "docs"))
              expect_true (any (grepl ("\\.md$", flist)))
              expect_true (file.exists (r))

              # Then add hex to README:
              chk <- file.copy ("../hex.png", file.path (path, "hex.png"))
              r <- file.path (path, "README.md")
              x <- brio::read_lines (r)
              x [1] <- paste0 (x [1],
                               " <img src='hex.png' align='right' ",
                               "height=210 width=182>")
              brio::write_lines (x, r)

              # TODO: That suppress warnings is because the hex logo is not yet
              # put in the proper place - do that!
              r <- suppressWarnings (convert_readme (path))
              x <- brio::read_lines (r)
              expect_false (grepl ("<img src", x [1]))
              expect_true (grep ("<img src", x) [1] > 1L)

              expect_false (dir.exists (file.path (path, "docs", "vignettes")))
              expect_output (convert_vignettes (path))
              expect_true (dir.exists (file.path (path, "docs", "vignettes")))

              unlink (path, recursive = TRUE)
})

# these tests don't work on r-univ machines because pandoc < required version
skip_if (!test_all)

test_that ("readthedocs & make functions", {

              pkg_name <- paste0 (sample (c (letters, LETTERS), size = 8),
                                  collapse = "")
              path <- rtd_dummy_pkg (pkg_name = pkg_name)
              expect_true (dir.exists (path))

              expect_false (dir.exists (file.path (path, "docs")))

              chk <- r2readthedocs (path, open = FALSE)

              expect_true (dir.exists (file.path (path, "docs")))
              expect_true (dir.exists (file.path (path, "docs", "_build")))
              expect_true (dir.exists (file.path (path,
                                                  "docs",
                                                  "_build",
                                                  "html")))
              expect_true (file.exists (file.path (path,
                                                   "docs",
                                                   "_build",
                                                   "html",
                                                   "index.html")))

              chk <- rtd_clean (path)
              expect_true (dir.exists (file.path (path, "docs")))
              # `_build` directory should be empty:
              flist <- list.files (file.path (path, "docs", "_build"),
                                   recursive = TRUE,
                                   all.files = TRUE)
              expect_length (flist, 0L)
              # But sub-dirs of "docs" should still be there:
              expect_true (dir.exists (file.path (path, "docs", "functions")))
              expect_true (dir.exists (file.path (path, "docs", "vignettes")))

              chk <- rtd_build (path)
              expect_true (dir.exists (file.path (path,
                                                  "docs",
                                                  "_build",
                                                  "html")))
              expect_true (file.exists (file.path (path,
                                                   "docs",
                                                   "_build",
                                                   "html",
                                                   "index.html")))

              chk <- rtd_clean (path, full = TRUE)
              expect_true (dir.exists (file.path (path, "docs")))
              # sub-dirs of "docs" should now be gone:
              expect_false (dir.exists (file.path (path, "docs", "functions")))
              expect_false (dir.exists (file.path (path, "docs", "vignettes")))
})
