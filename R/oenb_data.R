#' Download OeNB Data
#'
#' Download data sets from the OeNB's data web service \url{https://www.oenb.at/en/Statistics/User-Defined-Tables/webservice.html}.
#'
#' @param pos character vector specifying the position IDs of the indicators of interest.
#' See \code{\link{oenb_dataset}} to obtain the required ID.
#' @inheritParams oenb_metadata
#' @param freq Frequency of the data. Where available, possible values are
#' \code{"D"}, \code{"M"}, \code{"Q"}, \code{"H"}, \code{"A"}
#' for daily, monthly, quarterly, semi-annual and annual data.
#' See \code{\link{oenb_frequency}} to obtain possible choices.
#' @param attr A named vector of further attributes.
#' See \code{\link{oenb_attributes}} to obtain possible choices.
#' @param starttime character specifying the start of the series. See 'Details'.
#' @param endtime character specifying the end of the series. See 'Details'.
#' @inheritParams oenb_dataset
#'
#' @details The arguments `starttime` and `endtime` can have the format `YYYY-MM-DD` or
#' `YYYYMMDD` for daily data, `YYYY-MM` or `YYYYMM` for monthly data, and `YYYY` for
#' annual data. For semiannual data `YYYY-06` refers to the first half of year `YYYY` and
#' `YYYY-12` to the second. Similarly, for quarterly data `YYYY-03`, `YYYY-06`, `YYYY-09`
#' and `YYYY-12` refer to the first, second, third and forth quarter of year `YYYY`,
#' respectively.
#'
#' @return A data frame. \code{NULL} is returned if the query does not return any
#' data or if the web service is not available.
#'
#' @examples
#' \donttest{
#' series <- oenb_data(id = "11", pos = "VDBFKBSC217000", freq = "M", attr = c("dval1" = "AT"),
#'                     starttime = "2019-11", endtime = "2019-12")
#' series
#' }
#'
#' @export
oenb_data <- function(id, pos, freq = NULL, attr = NULL, starttime = NULL, endtime = NULL, lang = "EN") {
  oenb_check_lang(lang)

  url <- "https://www.oenb.at/isadataservice/data"
  url <- paste(url, "?lang=", lang, sep = "")
  url <- paste(url, "&hierid=", oenb_encode(id), sep = "")

  pos <- paste("pos=", oenb_encode(pos), sep = "", collapse = "&")
  url <- paste(url, "&", pos, sep = "")

  if (!is.null(freq)) {
    freq <- paste("freq=", oenb_encode(freq), sep = "", collapse = "&")
    url <- paste(url, "&", freq, sep = "")
  }
  if (!is.null(attr)) {
    attr <- paste(oenb_encode(names(attr)), "=", oenb_encode(attr), sep = "", collapse = "&")
    url <- paste(url, "&", attr, sep = "")
  }
  if (!is.null(starttime)) {
    url <- paste(url, "&starttime=", oenb_encode(starttime), sep = "")
  }
  if (!is.null(endtime)) {
    url <- paste(url, "&endtime=", oenb_encode(endtime), sep = "")
  }

  xml <- oenb_fetch(url)
  if (is.null(xml)) {
    return(NULL)
  }

  series <- XML::getNodeSet(xml, "//dataSet", fun = XML::xmlToList)
  if (length(series) == 0) {
    message("The query did not return any data. See oenb_frequency() and ",
            "oenb_attributes() for available periods and attributes of a series.")
    return(NULL)
  }

  result <- NULL
  for (i in seq_along(series)) {
    val_temp <- do.call(rbind, series[[i]]$values)
    period_temp <- val_temp[, "periode"]
    val_temp <- as.numeric(val_temp[, "value"])
    attr_temp <- as.data.frame(t(series[[i]]$.attrs), stringsAsFactors = FALSE)
    temp <- cbind("period" = period_temp,
                  attr_temp,
                  "value" = val_temp,
                  stringsAsFactors = FALSE)
    result <- rbind(result, temp)
  }
  names(result) <- tolower(names(result))

  temp_pos <- integer(0)
  if (length(which(grepl("dval", names(result), fixed = TRUE))) != 0) {
    temp_pos <- which(grepl("dval", names(result), fixed = TRUE))
  }
  # Added after OeNB seemed to have changed the output format of the xml
  if (length(which(grepl("attr", names(result), fixed = TRUE))) != 0) {
    temp_pos <- which(grepl("attr", names(result), fixed = TRUE))
  }

  if (length(temp_pos) > 0) {
    temp_frst <- seq_len(temp_pos[1] - 1)
    temp_scnd <- seq_len(length(names(result)))
    temp_scnd <- temp_scnd[temp_scnd > temp_pos[length(temp_pos)]]
    temp_names <- names(result)[temp_pos]
    # Order the attributes by their number rather than by their name. Sorting
    # the names would put "attr10" between "attr1" and "attr2" and separate an
    # attribute from the column that describes it, because "attr10" comes
    # before "attr2" alphabetically.
    temp_nr <- suppressWarnings(as.integer(gsub("\\D", "", temp_names)))
    temp_dim <- as.integer(grepl("dim$", temp_names))
    temp_pos <- temp_pos[order(temp_nr, temp_dim, temp_names)]
    temp_pos <- c(temp_frst, temp_pos, temp_scnd)
    result <- result[, temp_pos]
  }

  return(result)
}
