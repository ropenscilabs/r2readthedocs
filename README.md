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

1.  [‘readthedocs’](https://readthedocs.org/) is based on a markup
    language called [‘reStructuredText’
    (`.rst`)](https://www.python.org/dev/peps/pep-0287/#benefits) which
    is more flexible and powerful than the `markdown` generally used in
    R packages.
2.  The structure of an R package documentation website generated with
    existing tools such as [`pkgdown`](https://pkgdown.r-lib.org/) is
    generally fixed and difficult to modify. The entire structure of a
    [‘readthedocs’](https://readthedocs.org/) site can be very easily
    modified through changes to the underlying `.rst` files, including
    easy addition of documentation beyond the internal package-specific
    documentation, such as descriptions of use cases, of relevant data
    or analyses external to the package, or anything at all.

## How?

For those unfamiliar with [‘readthedocs’](https://readthedocs.org/)
(RTD), we recommend using the `rtd_dummy_pkg()` function provided with
this package, which generates a “skeleton” of a package which can be
used to generate an RTD site. Simply run the following two lines:

``` r
path <- rtd_dummy_pkg ()
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
adapted as desired.
