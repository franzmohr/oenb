#' Get Frequency
#'
#' Get potential frequencies of individual series from the OeNB's data webservice.
#'
#' @param pos character specifying the position ID of the indicator of interest.
#' See \code{\link{oenb_dataset}} to obtain the required ID.
#' @inheritParams oenb_dataset
#' @param div a named vector of attributes.
#'
#' @return A data frame containing available frequencies and periods of a series.
#'
#' @examples
#' series_freq <- oenb_frequency(id = "11", pos = "VDBFKBSC217000")
#' series_freq
#'
#' @export
oenb_frequency <- function(id, pos, div, lang = "EN") {
  if (!lang %in% c("DE", "EN")) {"Specified language is not supported."}

  url <- paste("https://www.oenb.at/isadataservice/datafrequency?lang=", lang, sep = "")
  url <- paste(url, "&hierid=", id, sep = "")
  url <- paste(url, "&pos=", pos, sep = "")

  xml <- XML::xmlParse(readLines(url))

  freq <- XML::xpathSApply(xml, "//periods", XML::xmlGetAttr, "frequency")
  avail <- XML::getNodeSet(xml, "//periods/available", fun = XML::xmlToList)
  avail <- unlist(avail)

  result <- data.frame("Frequency" = freq,
                       "Available Periods" = avail,
                       stringsAsFactors = FALSE)

  return(result)
}
