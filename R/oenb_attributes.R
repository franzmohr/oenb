#' Get Attributes
#'
#' Get potential attributes of individual series from the OeNB's data web service.
#'
#' @param pos character specifying the position ID of the indicator of interest.
#' See \code{\link{oenb_dataset}} to obtain the required ID.
#' @inheritParams oenb_dataset
#'
#' @return A data frame containing potential attributes of a series.
#' \code{NULL} is returned if the web service is not available.
#'
#' @examples
#' \donttest{
#' series_attr <- oenb_attributes(id = "11", pos = "VDBFKBSC217000")
#' series_attr
#' }
#'
#' @export
oenb_attributes <- function(id, pos, lang = "EN") {
  oenb_check_lang(lang)

  url <- paste("https://www.oenb.at/isadataservice/content?lang=", lang, sep = "")
  url <- paste(url, "&hierid=", oenb_encode(id), sep = "")
  url <- paste(url, "&pos=", oenb_encode(pos), sep = "")
  xml <- oenb_fetch(url)
  if (is.null(xml)) {
    return(NULL)
  }

  cols <- c("attribute_code", "attribute", "value_code", "value")

  nr_structure <- XML::xpathSApply(xml, "//structure/dimension", XML::xmlGetAttr, "nr")
  avail_nr <- XML::xpathSApply(xml, "//data/dimension", XML::xmlGetAttr, "nr")
  avail_code <- XML::xpathSApply(xml, "//auspraegung", XML::xmlGetAttr, "code")
  if (length(nr_structure) == 0 || length(avail_nr) == 0 ||
      length(avail_code) != length(avail_nr)) {
    message("No attributes were found for position \"", pos,
            "\" in data set \"", id, "\".")
    return(oenb_empty(cols))
  }

  dims_structure <- XML::getNodeSet(xml, "//structure", fun = XML::xmlToDataFrame,
                               stringsAsFactors = FALSE)[[1]][, 1]
  structure <- data.frame("nr" = nr_structure,
                          "attribute" = dims_structure,
                          stringsAsFactors = FALSE)

  avail_meta <- XML::getNodeSet(xml, "//auspraegung", fun = XML::xmlToDataFrame,
                                stringsAsFactors = FALSE)

  avail <- data.frame("nr" = avail_nr,
                      "code" = avail_code,
                      "text" = do.call(rbind, avail_meta),
                      stringsAsFactors = FALSE)
  avail <- dplyr::distinct(avail)

  result <- dplyr::left_join(structure, avail, by = "nr")
  result <- dplyr::select(result, "nr", "attribute", "code", "text")
  result <- as.data.frame(result)
  result$nr <- paste("dval", result$nr, sep = "")
  names(result) <- cols

  return(result)
}
