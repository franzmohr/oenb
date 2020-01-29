
<!-- README.md is generated from README.Rmd. Please edit that file -->

# oenb

[![CRAN
status](https://www.r-pkg.org/badges/version/oenb)](https://cran.r-project.org/package=oenb)
[![Travis build
status](https://travis-ci.org/franzmohr/oenb.svg?branch=master)](https://travis-ci.org/franzmohr/oenb)

`oenb` provides functions for the use of the statistical data webservice
of the Austrian national bank (Oesterreichische Nationalbank, OeNB).

## Installation

### Development version

``` r
# install.packages("devtools")
devtools::install_github("franzmohr/oenb")
```

## Usage

``` r
library(oenb)
```

### Table of content

``` r
toc <- oenb_toc()
head(toc)
#>          ID                                                    Title
#> 1         1                 OeNB, Eurosystem and Monetary Indicators
#> 2        11 Balance Sheet Items of the Oesterreichische Nationalbank
#> 3        13      Monetary Aggregates, Consolidated MFI Balance Sheet
#> 4        14             Debt Instruments, Deposits and Loans of MFIs
#> 5 100140001                                     Development of loans
#> 6 100140002             Debt Instruments, Deposits and Loans of MFIs
```

### Dataset overview

``` r
overview <- oenb_dataset(id = "11")
head(overview)
#>    Position Code
#> 1 VDBFKBSC217000
#> 2 VDBFKBSC217001
#> 3 VDBFKBSC217013
#> 4 VDBFKBSC217010
#> 5 VDBFKBSC317000
#> 6 VDBFKBSC317001
#>                                                                        Indicator
#> 1                                           Loans to euro area residents - total
#> 2                                            Loans to euro area residents - MFIs
#> 3                              Loans to euro area residents - general government
#> 4                                             Loans to other euro area residents
#> 5 Holdings of securities other than shares issued by euro area residents - total
#> 6   Collected within the framework of the balance sheet report to the ECB  MFIs.
```

### Attributes of a series

``` r
attrib <- oenb_attributes(id = "11", pos = "VDBFKBSC217000")
attrib
#>   Attribute Code                 Attribute Value Code
#> 1          dval1             Data producer         AT
#> 2          dval2            Banking sector    00100KI
#> 3          dval3 Region / business partner         AT
#> 4          dval4                  Currency        Z0Z
#>                           Value
#> 1                       Austria
#> 2 Oesterreichische Nationalbank
#> 3                       Austria
#> 4                Not applicable
```

### Data download

``` r
series <- oenb_data(id = "11", pos = "VDBFKBSC217000")
```

### Metadata

``` r
meta <- oenb_metadata(id = "11", pos = "VDBFKBSC217000")
meta
#>         Attribute
#> 1           title
#> 2          region
#> 3            unit
#> 4         comment
#> 5  classification
#> 6          breaks
#> 7       frequency
#> 8     last_update
#> 9          source
#> 10            lag
#>                                                                                                         Remark
#> 1                                                                         Loans to euro area residents - total
#> 2                                                                                                            -
#> 3                                                                                                         Euro
#> 4  Collected within the framework of the balance sheet report to the ECB  loans to euro area residents  total.
#> 5                                                                          European Sytem of National Accounts
#> 6                                                                                                            -
#> 7                                                                                                        month
#> 8                                                                                          2020-01-14 09:02:36
#> 9                                                                                                         OeNB
#> 10                                                                                                           -
```
