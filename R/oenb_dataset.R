#' Content of OeNB Data Sets
#'
#' Downloads a description of the contents of a specific dataset from the OeNB's data web service.
#'
#' @param id character specifying the ID of the dataset of interest.
#' See \code{\link{oenb_toc}} to obtain the required ID.
#' @inheritParams oenb_toc
#'
#' @return A data frame with one row per series of the data set and the columns
#' \describe{
#'   \item{\code{position_code}}{the position code of the series, which is the
#'   \code{pos} argument of the other functions.}
#'   \item{\code{description}}{the title of the series.}
#' }
#' A data frame without rows is returned if the data set contains no series.
#' \code{NULL} is returned if the web service is not available.
#' See \code{\link{oenb}} for the workflow and the conditions that are signalled.
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
    oenb_inform(paste0("No indicators were found for data set \"", id, "\". ",
                       "See oenb_toc() for available data set IDs."),
                "oenb_no_results", url = url)
    return(oenb_empty(c("position_code", "description")))
  }

  result <- data.frame(code, do.call(rbind, series), stringsAsFactors = FALSE)
  names(result) <- c("position_code", "description")
  return(result)
}
