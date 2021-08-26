
source ("../pkg-skeleton.R")

test_that("dummy package", {

              pkg_name <- paste0 (sample (c (letters, LETTERS), size = 8),
                                  collapse = "")
              d <- make_dummy_pkg (pkg_name = pkg_name)
              expect_true (dir.exists (d))

              rb <- file.path (d, ".Rbuildignore")
              expect_false (file.exists (rb))
              rignore_amend (d)
              expect_true (file.exists (rb))

              expect_false (dir.exists (file.path (d, "docs")))

              expect_silent (convert_man (d))
              expect_true (dir.exists (file.path (d, "docs")))
              expect_true (dir.exists (file.path (d, "docs", "functions")))

              flist <- list.files (file.path (d, "docs"))
              expect_false (any (grepl ("\\.md$", flist))) # no readme.md (-> random.md)

              expect_silent (r <- convert_readme (d))
              flist <- list.files (file.path (d, "docs"))
              expect_true (any (grepl ("\\.md$", flist)))
              expect_true (file.exists (r))

              # Then add hex to README:
              chk <- file.copy ("../hex.png", file.path (d, "hex.png"))
              r <- file.path (d, "README.md")
              x <- brio::read_lines (r)
              x [1] <- paste0 (x [1], 
                               " <img src='hex.png' align='right' height=210 width=182>")
              brio::write_lines (x, r)

              # TODO: That suppress warnings is because the hex logo is not yet
              # put in the proper place - do that!
              r <- suppressWarnings (convert_readme (d))
              x <- brio::read_lines (r)
              expect_false (grepl ("<img src", x [1]))
              expect_true (grep ("<img src", x) [1] > 1L)

              expect_false (dir.exists (file.path (d, "docs", "vignettes")))
              expect_output (convert_vignettes (d))
              expect_true (dir.exists (file.path (d, "docs", "vignettes")))

              unlink (d, recursive = TRUE)
})
