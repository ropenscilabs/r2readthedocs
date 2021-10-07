<!-- badges: start -->

[![R build
status](https://github.com/ropenscilabs/r2readthedocs/workflows/R-CMD-check/badge.svg)](https://github.com/ropenscilabs/r2readthedocs/actions)
[![codecov](https://codecov.io/gh/ropenscilabs/r2readthedocs/branch/main/graph/badge.svg)](https://codecov.io/gh/ropenscilabs/r2readthedocs)
[![Project Status:
Concept](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
<!-- badges: end -->

# r2readthedocs

Convert R package documentation to a
[‘readthedocs’](https://readthedocs.org/) website.

## Why?

Two compelling reasons:

1.  R packages are not necessarily self-contained, yet much of the
    surrounding infrastructure, from CRAN to automatic documentation
    generators such as [`pkgdown`](https://pkgdown.r-lib.org/), presume
    a package to be a self-contained unit. Any projects requiring
    greater flexibility must employ alternative documentation systems,
    for which [‘readthedocs’](https://readthedocs.org/) (RTD) offers an
    extremely simple and highly flexible way to embed or enhance package
    documentation within or alongside almost anything else.
2.  [‘readthedocs’](https://readthedocs.org/) is based on a markup
    language called [‘reStructuredText’
    (`.rst`)](https://docutils.sourceforge.io/docs/user/rst/quickref.html),
    which is more flexible and powerful than the `markdown` generally
    used in R packages.

## How?

For those unfamiliar with [‘readthedocs’](https://readthedocs.org/)
(RTD), we recommend using the `rtd_dummy_pkg()` function provided with
this package, which generates a “skeleton” of a package which can be
used to generate an RTD site.

``` r
path <- rtd_dummy_pkg ()
```

Then either using that `path` to the dummy package, or a local path to a
package of your choice, generate an RTD website by running:

``` r
r2readthedocs (path)
```

The RTD website will be automatically opened in your default browser.
Most of the content is automatically generated straight from the package
documentation, as for a [`pkgdown`](https://pkgdown.r-lib.org/) website.
The primary difference you’ll immediate notice is that the front page is
not the package’s `README.md` document. This is because, which
`markdown` pages can be readily inserted into `.rst` pages, this is not
possible for the main page, which must be encoded entirely in `.rst`
form. The front page of any site generated with the `r2readthedocs()`
function will retain this general form, which can then be readily
adapted as desired. The main file controlling the site’s appearance is
`index.rst`, located in a sub-directory of the local `path` named
`"docs"` - in R terms, at `file.path(path, "docs", "index.rst")`.

## Further Information

An RTD site is primarily determined by a few simple files. The
`r2readthedocs()` function initially inserts these files, and then
generates the entire site, creating a `"docs"` sub-directory with a
large number of files. The `rtd_clean()` function can be used to remove
all files automatically generated by RTD itself, reducing the files down
to the primary set of files controlling the site’s structure and
appearance. These are:

1.  `index.rst` responsible for the structure of the main page of the
    site.
2.  `conf.py` A python script for configuring aspects of the site.
3.  `requirements.txt` containing a list of required python packages,
    which may be extended as desired.
4.  `make.bat` and `Makefile` which are responsible for the main build
    system, and should **not** be modified. Type `make` in the local
    `"docs"` directory to see a full list of `make` options.

The main RTD documentation files can be re-generated at any time with
`rtd_build()`.
