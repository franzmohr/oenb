#' Content of OeNB Data Sets
#'
#' Downloads a description of the contents of a specific dataset from the OeNB's data web service.
#'
#' @param id character specifying the ID of the dataset of interest.
#' See \code{\link{oenb_toc}} to obtain the required ID.
#' @inheritParams oenb_toc
#'
#' @return A data frame containing the IDs and names of available indicators within a dataset.
#' \code{NULL} is returned if the web service is not available.
#'
#' @examples
#' \donttest{
#' content <- oenb_dataset(id = "11")
#' content
#' }
#'
#' @export
oenb_dataset <- function(id, lang = "EN") {
  oenb_check_lang(lang)

  url <- paste("https://www.oenb.at/isadataservice/content?lang=", lang, sep = "")
  url <- paste(url, "&hierid=", oenb_encode(id), sep = "")
  xml <- oenb_fetch(url)
  if (is.null(xml)) {
    return(NULL)
  }

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
  if (length(series) == 0 || length(code) != length(series)) {
    message("No indicators were found for data set \"", id, "\". ",
            "See oenb_toc() for available data set IDs.")
    return(oenb_empty(c("position_code", "description")))
  }

  result <- data.frame(code, do.call(rbind, series), stringsAsFactors = FALSE)
  names(result) <- c("position_code", "description")
  return(result)
}
