# `rtd_clean`

Clean the RTD _build directory


## Description

Clean the RTD _build directory


## Usage

```r
rtd_clean(path = ".", full = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`path`     |     Path to local R package with documentation to be converted
`full`     |     If `TRUE` , also clean R package files, including vignettes and help files. Use [r2readthedocs](#r2readthedocs) to re-generate these.
