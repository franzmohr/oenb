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

  # Only the single-valued fields of the block describe the indicator. Nested
  # elements such as 'data_available' or 'releases' are skipped, whether they
  # contain one entry or several: a nested element of length one would
  # otherwise pass for a field of its own and contribute the name of its child
  # instead of the name of the column.
  entries <- which(vapply(meta, function(x) {is.atomic(x) && length(x) == 1},
                          logical(1)))
  if (length(entries) == 0) {
    message("No metadata were found for position \"", pos,
            "\" in data set \"", id, "\".")
    return(oenb_empty(cols))
  }

  result <- data.frame("attribute" = names(meta)[entries],
                       "description" = as.character(unlist(meta[entries],
                                                           use.names = FALSE)),
                       stringsAsFactors = FALSE)

  return(result)
}
