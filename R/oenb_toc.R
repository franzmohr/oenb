#' Table of Contents
#'
#' Downloads the table of contents of the OeNB's statistical data web service.
#'
#' @param lang Preferred language of the output. Possible values are "DE" for
#' German and "EN" for English (default).
#'
#' @return A data frame with one row per data set and the columns
#' \describe{
#'   \item{\code{dataset_id}}{the ID of the data set, which is the \code{id}
#'   argument of the other functions.}
#'   \item{\code{description}}{the title of the data set.}
#' }
#' \code{NULL} is returned if the web service is not available.
#' See \code{\link{oenb}} for the workflow and the conditions that are signalled.
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
    oenb_inform("The data web service of the OeNB did not return any data sets.",
                "oenb_no_results", url = url)
    return(oenb_empty(c("dataset_id", "description")))
  }

  result <- data.frame(code, do.call(rbind, out), stringsAsFactors = FALSE)
  names(result) <- c("dataset_id", "description")
  return(result)
}
