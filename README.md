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
