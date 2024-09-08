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

#' Find the Internal ID of a Symbol
#'
#' @param symbol A character string representing the symbol of the stock.
#'
#' @importFrom httr parse_url
#' @importFrom stringr str_glue
#' @importFrom jsonlite fromJSON
#'
find_symbol_id <- function(symbol) {
    url <- httr::parse_url("https://www.casablanca-bourse.com/")
    url$path <- stringr::str_glue(
        "_next/data/6lgwZ8lO-4XZP6GZNwHjq/en/live-market/instruments/{symbol}.json"
    )
    url$query <- list(
        slug = "live-market",
        slug = "instruments",
        slug = symbol
    )
    symbol_json <- jsonlite::fromJSON(httr::build_url(url))
    symbol_id <- symbol_json$pageProps$node$field_vactory_paragraphs %>%
        .$field_vactory_component %>% .$widget_data %>% .[[1]] %>%
        jsonlite::fromJSON() %>% .$components %>% .$collection %>%
        .$filters %>% .$filter %>% .$drupal_internal__id
    return(symbol_id)
}


#' Construct URL for Historical Data
#'
#' @param symbol A character string representing the symbol of the stock.
#' @param start_date A character string representing the start date of the data.
#' @param end_date A character string representing the end date of the data.
#'
#' @note The format of start_date and end_date should be "YYYY-MM-DD".
#'
#' @importFrom httr parse_url build_url
#'
url_constructor <- function(symbol, start_date, end_date) {
    symbol_id <- find_symbol_id(symbol)
    url <- httr::parse_url("https://api.casablanca-bourse.com/")
    url$path <- "en/api/bourse_data/instrument_history"
    url$query <- list(
        `fields[instrument_history]` = paste("symbol", "created",
                                             "openingPrice", "coursCourant",
                                             "highPrice", "lowPrice",
                                             "cumulTitresEchanges",
                                             "cumulVolumeEchange",
                                             "totalTrades", "capitalisation",
                                             "coursAjuste", "closingPrice",
                                             "ratioConsolide", sep = ","),
        `fields[instrument]` = paste("symbol", "libelleFR", "libelleAR",
                                     "libelleEN", "emetteur_url",
                                     "instrument_url", sep = ","),
        `fields[taxonomy_term--bourse_emetteur]` = "name",
        include = "symbol",
        `sort[date-seance][direction]` = "DESC",
        `sort[date-seance][langcode]` = "",
        `sort[date-seance][path]` = "created",
        `filter[filter-historique-instrument-emetteur][condition][path]` =
            "symbol.meta.drupal_internal__target_id",
        `filter[filter-historique-instrument-emetteur][condition][value]` =
            symbol_id,
        `filter[filter-historique-instrument-emetteur][condition][operator]` =
            "=",
        `filter[instrument-history-class][condition][path]` =
            "symbol.codeClasse.field_code",
        `filter[instrument-history-class][condition][value]` = "1",
        `filter[instrument-history-class][condition][operator]` = "=",
        `filter[published]` = "1",
        `filter[filter-date-start-vh][condition][path]` = "field_seance_date",
        `filter[filter-date-start-vh][condition][operator]` = ">=",
        `filter[filter-date-start-vh][condition][value]` = start_date,
        `filter[filter-date-end-vh][condition][path]` = "field_seance_date",
        `filter[filter-date-end-vh][condition][operator]` = "<=",
        `filter[filter-date-end-vh][condition][value]` = end_date,
        `page[offset]` = "0",
        `page[limit]` = "50"
    )
    return(httr::build_url(url))
}
