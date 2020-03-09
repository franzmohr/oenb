#' Download OeNB Data
#'
#' Download data sets from the OeNB's data web service \url{https://www.oenb.at/en/Statistics/User-Defined-Tables/webservice.html}.
#'
#' @param pos character vector specifying the position IDs of the indicators of interest.
#' See \code{\link{oenb_dataset}} to obtain the required ID.
#' @inheritParams oenb_metadata
#' @param freq Frequency of the data. Where available, possible values are
#' \code{"D"}, \code{"M"}, \code{"Q"}, \code{"H"}, \code{"A"}
#' for daily, monthly, quarterly, semi-annual and annual data.
#' See \code{\link{oenb_frequency}} to obtain possible choices.
#' @param attr A named vector of further attributes.
#' See \code{\link{oenb_attributes}} to obtain possible choices.
#' @param starttime character specifying the start of the series. See 'Details'.
#' @param endtime character specifying the end of the series. See 'Details'.
#' @inheritParams oenb_dataset
#'
#' @details The arguments `starttime` and `endtime` can have the format `YYYY-MM-DD` or
#' `YYYYMMDD` for daily data, `YYYY-MM` or `YYYYMM` for monthly data, and `YYYY` for
#' annual data. For semiannual data `YYYY-06` refers to the first half of year `YYYY` and
#' `YYYY-12` to the second. Similarly, for quarterly data `YYYY-03`, `YYYY-06`, `YYYY-09`
#' and `YYYY-12` refer to the first, second, third and forth quarter of year `YYYY`,
#' respectively.
#'
#' @return A data frame.
#'
#' @examples
#' \donttest{
#' series <- oenb_data(id = "11", pos = "VDBFKBSC217000", freq = "M", attr = c("dval1" = "AT"),
#'                     starttime = "2019-11", endtime = "2019-12")
#' series
#' }
#'
#' @export
oenb_data <- function(id, pos, freq = NULL, attr = NULL, starttime = NULL, endtime = NULL, lang = "EN") {
  if (!lang %in% c("DE", "EN")) {"Specified language is not supported."}
  url <- "https://www.oenb.at/isadataservice/data"
  url <- paste(url, "?lang=", lang, sep = "")
  url <- paste(url, "&hierid=", id, sep = "")

  pos <- paste("pos=", pos, sep = "", collapse = "&")
  url <- paste(url, "&", pos, sep = "")

  if (!is.null(freq)) {
    freq <- paste("freq=", freq, sep = "", collapse = "&")
    url <- paste(url, "&", freq, sep = "")
  }
  if (!is.null(attr)) {
    attr <- paste(names(attr), "=", attr, sep = "", collapse = "&")
    url <- paste(url, "&", attr, sep = "")
  }
  if (!is.null(starttime)) {
    url <- paste(url, "&starttime=", starttime, sep = "")
  }
  if (!is.null(endtime)) {
    url <- paste(url, "&endtime=", endtime, sep = "")
  }

  xml <- XML::xmlParse(readLines(url))

  series <- XML::getNodeSet(xml, "//dataSet", fun = XML::xmlToList)

  result <- NULL
  if (length(series) > 0) {
    for (i in 1:length(series)) {
      val_temp <- do.call(rbind, series[[i]]$values)
      period_temp <- val_temp[, "periode"]
      val_temp <- as.numeric(val_temp[, "value"])
      attr_temp <- as.data.frame(t(series[[i]]$.attrs), stringsAsFactors = FALSE)
      temp <- cbind("period" = period_temp,
                    attr_temp,
                    "value" = val_temp,
                    stringsAsFactors = FALSE)
      result <- rbind(result, temp)
    }
    names(result) <- tolower(names(result))
  }

  temp_pos <- which(grepl("dval", names(result), fixed = TRUE))
  temp_frst <- 1:(temp_pos[1] - 1)
  temp_scnd <- (temp_pos[length(temp_pos)] + 1):length(names(result))
  temp_names <- names(result)[temp_pos]
  temp_pos <- temp_pos[order(temp_names)]
  temp_pos <- c(temp_frst, temp_pos, temp_scnd)
  result <- result[, temp_pos]

  return(result)
}
