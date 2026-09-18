#' Get Frequency
#'
#' Get available frequencies and periods of individual series from the OeNB's data web service.
#'
#' @param pos character specifying the position ID of the indicator of interest.
#' See \code{\link{oenb_dataset}} to obtain the required ID.
#' @inheritParams oenb_dataset
#'
#' @return A data frame containing available frequencies and periods of a series.
#' \code{NULL} is returned if the web service is not available.
#'
#' @examples
#' \donttest{
#' series_freq <- oenb_frequency(id = "11", pos = "VDBFKBSC217000")
#' series_freq
#' }
#'
#' @export
oenb_frequency <- function(id, pos, lang = "EN") {
  oenb_check_lang(lang)

  url <- paste("https://www.oenb.at/isadataservice/datafrequency?lang=", lang, sep = "")
  url <- paste(url, "&hierid=", oenb_encode(id), sep = "")
  url <- paste(url, "&pos=", oenb_encode(pos), sep = "")

  xml <- oenb_fetch(url)
  if (is.null(xml)) {
    return(NULL)
  }

  freq <- XML::xpathSApply(xml, "//periods", XML::xmlGetAttr, "frequency")
  avail <- XML::getNodeSet(xml, "//periods/available", fun = XML::xmlToList)
  avail <- unlist(avail)
  if (length(freq) == 0 || length(avail) != length(freq)) {
    message("No frequencies were found for position \"", pos,
            "\" in data set \"", id, "\".")
    return(oenb_empty(c("frequency", "available_period")))
  }

  result <- data.frame("frequency" = freq,
                       "available_period" = avail,
                       stringsAsFactors = FALSE)

  return(result)
}
