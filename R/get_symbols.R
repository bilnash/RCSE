################################################################################
## Copyright (C) 2024 Bilal ELMSILI <bilal_elmsili@um5.ac.ma>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA
################################################################################


#' Get Available Symbols From Casablanca Stock Exchange
#'
#' @description
#' This function retrieves all traded symbols in Casablanca Stock Exchange.
#'
#' @return A tibble with the following columns: name, id, isin, ipo_date,
#' shares_count, ipo_price, nominal_value, shares_number.
#'
#'
#' @importFrom jsonlite fromJSON
#' @importFrom tibble tibble
#' @importFrom dplyr mutate
#' @importFrom lubridate as_date
#' @importFrom purrr map_df
#' @importFrom magrittr %>%
#' @importFrom httr GET user_agent http_status content
#'
#' @export
#'
get_symbols <- function() {

    url <- "https://api.casablanca-bourse.com/fr/api/node/instrument"

    response <- httr::GET(url,
                          httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"))

    if (httr::http_status(response)$category != "Success") {
        stop("Failed to fetch data. Status: ", httr::http_status(response)$message)
    }

    symbols_json <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))

    symbols_df <- symbols_json$data$attributes$field_instrument_list %>%
        .[[1]] %>% tibble::as_tibble() %>%
        dplyr::rename(symbol = url) %>%
        dplyr::mutate(symbol = stringr::str_remove(symbol,
                                                   "/fr/live-market/instruments/")
        )
    return(symbols_df)
}















