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
#' @return A data frame.
#'
#' @examples
#' \dontrun{
#' series <- oenb_data(id = "11", pos = "VDBFKBSC217000", freq = "M", attr = c("dval1" = "AT"))
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

  return(result)
}
