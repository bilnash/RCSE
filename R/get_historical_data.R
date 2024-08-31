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


#'
#' @importFrom httr parse_url build_url
#'
build_url <- function(symbol_code, start_date, end_date) {
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
            symbol_code,
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
