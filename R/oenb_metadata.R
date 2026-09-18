#' Get Metadata
#'
#' Get metadata on individual series from the OeNB's data web service.
#'
#' @param pos character specifying the position ID of the indicator of interest.
#' See \code{\link{oenb_dataset}} to obtain the required ID.
#' @inheritParams oenb_dataset
#'
#' @return A data frame containing metadata on an indicator.
#' \code{NULL} is returned if the web service is not available.
#'
#' @examples
#' \donttest{
#' meta <- oenb_metadata(id = "11", pos = "VDBFKBSC217000")
#' meta
#' }
#'
#' @export
oenb_metadata <- function(id, pos, lang = "EN") {
  oenb_check_lang(lang)

  url <- paste("https://www.oenb.at/isadataservice/meta?lang=", lang, sep = "")
  url <- paste(url, "&hierid=", oenb_encode(id), sep = "")
  url <- paste(url, "&pos=", oenb_encode(pos), sep = "")
  xml <- oenb_fetch(url)
  if (is.null(xml)) {
    return(NULL)
  }

  cols <- c("attribute", "description")

  meta <- XML::getNodeSet(xml, "//meta", fun = XML::xmlToList)
  if (length(meta) == 0) {
    message("No metadata were found for position \"", pos,
            "\" in data set \"", id, "\".")
    return(oenb_empty(cols))
  }
  meta <- meta[[1]]

  entries <- which(unlist(lapply(meta, function(x) {length(x) == 1})))
  if (length(entries) == 0) {
    message("No metadata were found for position \"", pos,
            "\" in data set \"", id, "\".")
    return(oenb_empty(cols))
  }

  result <- NULL
  for (i in entries) {
    temp <- data.frame("attribute" = names(meta)[i],
                       "description" = meta[[i]], stringsAsFactors = FALSE)
    result <- rbind(result, temp)
  }

  return(result)
}
