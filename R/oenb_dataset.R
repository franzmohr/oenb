#' Content of OeNB Data Sets
#'
#' Downloads a description of the contents of a specific dataset from the OeNB's data web service.
#'
#' @param id character specifying the ID of the dataset of interest.
#' See \code{\link{oenb_toc}} to obtain the required ID.
#' @inheritParams oenb_toc
#'
#' @return A data frame containing the IDs and names of available indicators within a dataset.
#'
#' @examples
#' content <- oenb_dataset(id = 11)
#' content
#'
#' @export
oenb_dataset <- function(id, lang = "EN") {
  if (!lang %in% c("DE", "EN")) {"Specified language is not supported."}
  url <- paste("https://www.oenb.at/isadataservice/content?lang=", lang, sep = "")
  url <- paste(url, "&hierid=", id, sep = "")
  xml <- XML::xmlParse(readLines(url))

  filter <- "//group[@name="
  if (lang == "EN") {
    filter <- paste(filter, "'all data'", sep = "")
  }
  if (lang == "DE") {
    filter <- paste(filter, "'alle Daten'", sep = "")
  }
  filter <- paste(filter,  "]//position", sep = "")


  series <- XML::getNodeSet(xml, filter, fun = XML::xmlToDataFrame,
                            stringsAsFactors = FALSE)
  code <- XML::xpathSApply(xml, filter, XML::xmlGetAttr, "id")

  result <- data.frame(code, do.call(rbind, series))
  names(result) <- c("position_code", "description")
  return(result)
}
