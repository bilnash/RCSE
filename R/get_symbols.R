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
#'
#' @export
#'
get_symbols <- function() {
    url <- paste0("https://api.casablanca-bourse.com/",
                  "en/api/paragraph/vactory_component/",
                  "89109b3a-143e-40a2-b259-b0934fa5da98")
    symbols_json <- jsonlite::fromJSON(url)
    symbols_json <- symbols_json$data$attributes$field_vactory_component$widget_data
    symbols_uuid <- jsonlite::fromJSON(symbols_json)$instruments$uuid
    symbols_df <- symbols_uuid %>%
        purrr::map_df(
            function(symbol_uuid) {
                symbol_url <- paste0("https://api.casablanca-bourse.com/",
                                     "en/api/bourse_data/instrument/",
                                     symbol_uuid)
                symbol_json <- jsonlite::fromJSON(symbol_url)
                symbol_df <- tibble::tibble(
                    name = symbol_json$data$attributes$libelleFR,
                    id = symbol_json$data$attributes$drupal_internal__id,
                    isin = symbol_json$data$attributes$codeISIN,
                    ipo_date = symbol_json$data$attributes$dateIntroduction,
                    shares_count = symbol_json$data$attributes$nombreTitres,
                    ipo_price = symbol_json$data$attributes$coursIntroduction,
                    nominal_value = symbol_json$data$attributes$valeurNominale,
                )
                return(symbol_df)
            }, .progress = TRUE
        )
    symbols_df %>% dplyr::mutate(
        ipo_date = lubridate::as_date(ipo_date),
        ipo_price = as.numeric(ipo_price),
        nominal_value = as.numeric(nominal_value),
        shares_number = as.integer(shares_number)
    )
    return(symbols_df)
}















