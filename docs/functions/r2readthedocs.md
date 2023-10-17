# `r2readthedocs`

Convert package documentation to `readthedocs` format


## Description

Convert package documentation to `readthedocs` format


## Usage

```r
r2readthedocs(path = here::here(), dev = FALSE, open = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`path`     |     Path to local R package with documentation to be converted
`dev`     |     If `TRUE` , include function documentation of all dependency packages in site.
`open`     |     If `TRUE` , open the documentation site in default browser.


## Value

TRUE (invisibly) if documentation successfully converted.
