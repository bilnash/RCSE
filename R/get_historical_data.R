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
#' @importFrom xml2 read_html xml_find_first as_list
#'
find_symbol_id <- function(symbol) {
    build_id <- xml2::read_html(
        stringr::str_glue(
            "https://www.casablanca-bourse.com/fr/live-market/instruments/{symbol}"
        )) %>%
        xml2::xml_find_first(xpath = "//*[@id='__NEXT_DATA__']") %>%
        xml2::as_list() %>%
        .[[1]] %>%
        jsonlite::fromJSON() %>% .$buildId
    url <- httr::parse_url("https://www.casablanca-bourse.com/")
    url$path <- stringr::str_glue(
        "_next/data/{build_id}/en/live-market/instruments/{symbol}.json"
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

#' Parse Date
#'
#' Parse start_date and end_date in the correct format.
#'
#' @param date A character string representing the date.
#'
#' @return A date object.
#'
#' @importFrom lubridate parse_date_time
#' @importFrom magrittr '%>%'
#'
#'
parse_date <- function(date) {

    tryCatch({
        date <- lubridate::parse_date_time(date,
                                           orders = c("ymd", "dmy", "mdy")) %>%
            as.Date()
    }, warning = function(w) {
        stop("Invalid date format. Valid formats are:
             'YYYY-MM-DD' or 'MM-DD-YYYY' or 'DD-MM-YYYY'.")
    })

    return(date)
}

#' Validate Dates
#'
#' Check if start_date and end_date are valid.
#'
#' @param start_date A date object representing the start date.
#' @param end_date A date object representing the end date.
#'
#' @return TRUE if the dates are valid.
#'
#' @importFrom lubridate is.Date years
#'
#'
validate_dates <- function(start_date, end_date) {

    stopifnot(lubridate::is.Date(start_date), lubridate::is.Date(end_date))

    if (start_date > Sys.Date() | end_date > Sys.Date()) {
        stop("Dates should not be in the future.")
    }

    if (start_date > end_date) {
        stop("start_date should be before end_date.")
    }

    if (start_date < Sys.Date() - lubridate::years(3) &
        end_date < Sys.Date() - lubridate::years(3)) {
        warning(
            "API returns only the previous 3 years. Requested Data might not be available."
        )
    } else if (start_date < Sys.Date() - lubridate::years(3)) {
        warning(
            "API returns only the previous 3 years. Requested Data might not be complete."
        )
    }

    return(TRUE)

}


#' Get Historical Data
#'
#' Retrieves historical data of a stock from the Casablanca Stock Exchange.
#'
#' @param symbol A character string representing the symbol of the stock.
#' @param start_date A character string representing the start date of the data.
#' @param end_date A character string representing the end date of the data.
#'
#' @note The format of start_date and end_date should be "YYYY-MM-DD".
#' @note Use the function get_symbols() to get the list of available symbols.
#' @note The API returns only the previous 3 years of data.
#'
#' @return A data frame containing the historical data of the stock.
#'
#' @importFrom dplyr bind_rows
#' @importFrom jsonlite fromJSON
#' @importFrom tibble tibble
#' @importFrom lubridate years days
#'
#' @export
#'
get_historical_data <- function(symbol,
                                start_date = NULL,
                                end_date = NULL) {

    if(is.null(start_date)) {
        start_date = Sys.Date() - lubridate::years(3)
    }

    if(is.null(end_date)) {
        end_date = Sys.Date()
    }

    if(is.character(start_date)) {
        start_date <- parse_date(start_date)
    }

    if(is.character(end_date)) {
        end_date <- parse_date(end_date)
    }

    validate_dates(start_date, end_date)

    start_date <- format(start_date, "%Y-%m-%d")
    end_date <- format(end_date, "%Y-%m-%d")

    url <- url_constructor(symbol, start_date, end_date)

    hist_data <- tibble::tibble()
    while(!is.null(url)) {
        json_data <- jsonlite::fromJSON(url)
        df_data <- tibble::tibble(
            #symbol = json_data$included$attributes$libelleEN,
            date = as.Date(json_data$data$attributes$created),
            open = as.numeric(json_data$data$attributes$openingPrice),
            high = as.numeric(json_data$data$attributes$highPrice),
            low = as.numeric(json_data$data$attributes$lowPrice),
            close = as.numeric(json_data$data$attributes$closingPrice),
            adjusted = as.numeric(json_data$data$attributes$coursAjuste),
            quantity_exchanged = as.integer(
                json_data$data$attributes$cumulTitresEchanges),
            volume = as.numeric(json_data$data$attributes$cumulVolumeEchange),
            total_trades = as.integer(json_data$data$attributes$totalTrades),
            capitalisation = as.numeric(json_data$data$attributes$capitalisation),
        )
        hist_data <- dplyr::bind_rows(hist_data, df_data)
        url <- json_data$links$`next`$href
    }

    return(hist_data)
}







