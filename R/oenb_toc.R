#' Table of Contents
#'
#' Downloads the table of contents of the OeNB's statistical data web service.
#'
#' @param lang Preferred language of the output. Possible values are "DE" for
#' German and "EN" for English (default).
#'
#' @return A data frame containing the IDs and titles of available datasets.
#' \code{NULL} is returned if the web service is not available.
#'
#' @examples
#' \donttest{
#' toc <- oenb_toc()
#' toc
#' }
#'
#' @export
oenb_toc <- function(lang = "EN") {
  oenb_check_lang(lang)

  url <- paste("https://www.oenb.at/isadataservice/content?lang=", lang, sep = "")
  xml <- oenb_fetch(url)
  if (is.null(xml)) {
    return(NULL)
  }

  out <- XML::getNodeSet(xml, "//element", fun = XML::xmlToDataFrame, stringsAsFactors = FALSE)
  code <- XML::xpathSApply(xml, "//element", XML::xmlGetAttr, "id")
  if (length(out) == 0 || length(code) != length(out)) {
    message("The data web service of the OeNB did not return any data sets.")
    return(oenb_empty(c("dataset_id", "description")))
  }

  result <- data.frame(code, do.call(rbind, out), stringsAsFactors = FALSE)
  names(result) <- c("dataset_id", "description")
  return(result)
}
