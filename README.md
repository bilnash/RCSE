
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RCSE: Load and Manage Data from Casablanca Stock Exchange (Morocco)

<!-- badges: start -->

[![R-CMD-check](https://github.com/bilnash/RCSE/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bilnash/RCSE/actions/workflows/R-CMD-check.yaml)

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<!-- badges: end -->

The goal of RCSE is to provide an easy way to load and manage data from
Casablanca Stock Exchange (Morocco). The package is still under
development and will be updated regularly.

## Installation

You can install the development version of RCSE from
[GitHub](https://github.com/bilnash/RCSE) with:

``` r
# install.packages("devtools")
devtools::install_github("bilnash/RCSE")
```

## Example

### `get_symbols`

The function `get_symbols` allows you to get the list of symbols
available in the Casablanca Stock Exchange:

``` r
listed_symbols <- RCSE::get_symbols()
```

``` r
head(listed_symbols)
#> # A tibble: 6 × 2
#>   title               symbol
#>   <chr>               <chr> 
#> 1 AFMA                AFM   
#> 2 AFRIC INDUSTRIES SA AFI   
#> 3 AFRIQUIA GAZ        GAZ   
#> 4 AGMA                AGM   
#> 5 AKDITAL             AKT   
#> 6 ALLIANCES           ADI
```

### `get_historical_data`

The function `get_historical_data` allows you to get the historical data
of a given symbol. This function takes in three arguments: `symbol`,
`start_date`, and `end_date`.

If `start_date` and `end_date` are not provided, the function will
return the historical data of the last 3 years (Casablanca Stock
Exchange API limit is 3 years).

Use the function `get_symbols` to get the list of symbols available in
the Casablanca Stock Exchange.

``` r
atw_data <- RCSE::get_historical_data("ATW")
```

``` r
dim(atw_data)
#> [1] 750  10
```

``` r
head(atw_data)
#> # A tibble: 6 × 10
#>   date        open  high   low close adjusted quantity_exchanged     volume
#>   <date>     <dbl> <dbl> <dbl> <dbl>    <dbl>              <int>      <dbl>
#> 1 2024-09-27  546   555   545.  555      555              154888  85483912.
#> 2 2024-09-26  548   550   546   550      550               25732  14129613.
#> 3 2024-09-25  547   559.  547   550      550              218367 120119821.
#> 4 2024-09-24  555   565.  546   547.     547.             181993 100631932.
#> 5 2024-09-23  546.  550   546.  550.     550.              19806  10875601.
#> 6 2024-09-20  553   555.  547   550.     550.              51560  28356446.
#> # ℹ 2 more variables: total_trades <int>, capitalisation <dbl>
```

Here is an example with a specific date range:

``` r
akt_data <- RCSE::get_historical_data("AKT", start_date = "2024-06-15", end_date = "2024-09-26")
```

``` r
dim(akt_data)
#> [1] 66 10
```

``` r
head(akt_data)
#> # A tibble: 6 × 10
#>   date        open  high   low close adjusted quantity_exchanged   volume
#>   <date>     <dbl> <dbl> <dbl> <dbl>    <dbl>              <int>    <dbl>
#> 1 2024-09-26  1084  1119  1083  1105     1105              33361 36579970
#> 2 2024-09-25  1024  1070  1017  1062     1062              49746 52299926
#> 3 2024-09-24  1025  1049  1013  1016     1016              24179 24985981
#> 4 2024-09-23  1008  1025  1008  1025     1025              23984 24411569
#> 5 2024-09-20  1006  1008  1003  1005     1005              46141 46369176
#> 6 2024-09-19  1005  1010  1000  1002     1002              10448 10491782
#> # ℹ 2 more variables: total_trades <int>, capitalisation <dbl>
```
