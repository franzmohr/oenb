
# oenb

[![CRAN
status](https://www.r-pkg.org/badges/version/oenb)](https://cran.r-project.org/package=oenb)
[![Build
Status](https://app.travis-ci.com/franzmohr/oenb.svg?branch=master)](https://app.travis-ci.com/franzmohr/oenb)

The `oenb` R package provides tools to access statistical data via the
[web service of the Austrian central
bank](https://www.oenb.at/en/Statistics/User-Defined-Tables/webservice.html)
(Oesterreichische Nationalbank, OeNB).

## Installation

``` r
install.packages("oenb") 
```

### Development version

``` r
# install.packages("devtools")
devtools::install_github("franzmohr/oenb")
```

## Usage

``` r
library("oenb")
```

### Table of contents

A table of available data sets can be obtained with the function
`oenb_toc`. Its output contains the ID of the data set with a short
description.

``` r
toc <- oenb_toc()
head(toc)
#>   dataset_id                                              description
#> 1          1                 OeNB, Eurosystem and Monetary Indicators
#> 2         11 Balance Sheet Items of the Oesterreichische Nationalbank
#> 3         13      Monetary Aggregates, Consolidated MFI Balance Sheet
#> 4         14                               Loans and deposits of MFIs
#> 5  100140001                                     Development of loans
#> 6  100140002                               Loans and deposits of MFIs
```

### Dataset overview

Each data set contains a series of indicators. The function
`oenb_dataset` can be used to obtain a table of available series for a
given data set. Its output contains the position code of a series and a
short description.

``` r
overview <- oenb_dataset(id = "11")
head(overview)
#>    position_code
#> 1 VDBFKBSC217000
#> 2 VDBFKBSC217001
#> 3 VDBFKBSC217013
#> 4 VDBFKBSC217010
#> 5 VDBFKBSC317000
#> 6 VDBFKBSC317001
#>                                                                      description
#> 1                                           Loans to euro area residents - total
#> 2                                            Loans to euro area residents - MFIs
#> 3                              Loans to euro area residents - general government
#> 4                                             Loans to other euro area residents
#> 5 Holdings of securities other than shares issued by euro area residents - total
#> 6   Collected within the framework of the balance sheet report to the ECB  MFIs.
```

### Attributes of a series

Many series are available in different forms. The function
`oenb_attributes` obtains a table of available query specifications of a
given series.

``` r
attrib <- oenb_attributes(id = "11", pos = "VDBFKBSC217000")
attrib
#>   attribute_code                 attribute value_code
#> 1          dval1             Data producer         AT
#> 2          dval2            Banking sector    00100KI
#> 3          dval3 Region / business partner         AT
#> 4          dval4                  Currency        Z0Z
#>                           value
#> 1                       Austria
#> 2 Oesterreichische Nationalbank
#> 3                       Austria
#> 4                Not applicable
```

Furthermore, series are available in different frequencies. The function
`oenb_frequency` can be used to obtain the available frequencies of a
given series and the periods, for which data are available.

``` r
freq <- oenb_frequency(id = "11", pos = "VDBFKBSC217000")
freq
#>   frequency    available_period
#> 1         A         1998 - 2020
#> 2         M Jan.  98 - Sep.  21
```

### Data download

Series of a data set can be downloaded with the `oenb_data` function.

``` r
series <- oenb_data(id = "11", pos = "VDBFKBSC217000", attr = c("dval3" = "AT"))
```

### Metadata

Metadata on a specific series can be obtained with the function
`oenb_metadata`.

``` r
meta <- oenb_metadata(id = "11", pos = "VDBFKBSC217000")
meta
#>         attribute
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
#>                                                                                                    description
#> 1                                                                         Loans to euro area residents - total
#> 2                                                                                                            -
#> 3                                                                                                         Euro
#> 4  Collected within the framework of the balance sheet report to the ECB  loans to euro area residents  total.
#> 5                                                                          European Sytem of National Accounts
#> 6                                                                                                            -
#> 7                                                                                                        month
#> 8                                                                                          2021-10-14 12:51:36
#> 9                                                                                                         OeNB
#> 10                                                                                                           -
```
