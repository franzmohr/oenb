#' Table of Contents
#'
#' Downloads the table of contents of the OeNB's data webservice.
#'
#' @param lang Preferred language of the output. Possible values are "DE" for
#' German and "EN" for English (default).
#'
#' @return A data frame containing the IDs and titles of available datasets.
#'
#' @examples
#'
#' toc <- oenb_toc()
#' toc
#'
#' @export
oenb_toc <- function(lang = "EN") {
  if (!lang %in% c("DE", "EN")) {"Specified language is not supported."}
  url <- paste("https://www.oenb.at/isadataservice/content?lang=", lang, sep = "")
  xml <- XML::xmlParse(readLines(url))
  out <- XML::getNodeSet(xml, "//element", fun = XML::xmlToDataFrame, stringsAsFactors = FALSE)
  code <- XML::xpathSApply(xml, "//element", XML::xmlGetAttr, "id")
  result <- data.frame(code, do.call(rbind, out), stringsAsFactors = FALSE)
  names(result) <- c("ID", "Title")
  return(result)
}
