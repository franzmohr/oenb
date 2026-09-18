#' Internal helpers
#'
#' Helper functions that are shared by the exported functions of the package.
#' They are not exported.
#'
#' @param lang preferred language of the output.
#' @param x a vector of values that are pasted into a query string.
#' @param url the URL of a request to the OeNB's data web service.
#' @param cols names of the columns of an empty result.
#'
#' @name oenb-internal
#' @keywords internal
#' @noRd
NULL

# Stop if the requested language is not supported by the web service.
oenb_check_lang <- function(lang) {
  if (!is.character(lang) || length(lang) != 1 || is.na(lang) ||
      !lang %in% c("DE", "EN")) {
    stop("Specified language is not supported. Possible values are \"DE\" and \"EN\".",
         call. = FALSE)
  }
  invisible(NULL)
}

# Percent-encode values before they are pasted into a query string, so that
# arguments containing reserved characters do not produce a malformed URL.
# A missing value would silently become the string "NA" and produce a query
# that cannot be answered, so it is rejected instead.
oenb_encode <- function(x) {
  x <- as.character(x)
  if (anyNA(x)) {
    stop("Arguments of a query must not contain missing values.", call. = FALSE)
  }
  vapply(x, utils::URLencode, character(1), reserved = TRUE, USE.NAMES = FALSE)
}

# An empty result with the documented columns, so that code which expects a
# data frame keeps working when a query does not return anything.
oenb_empty <- function(cols) {
  result <- as.data.frame(matrix(character(), nrow = 0, ncol = length(cols)),
                          stringsAsFactors = FALSE)
  names(result) <- cols
  return(result)
}

# Download and parse an XML document from the web service.
#
# Returns NULL - with an informative message - if the service cannot be reached
# or its response cannot be parsed, so that the package fails gracefully when
# the resource is unavailable. If the service reports a problem with the query
# itself, its error message is passed on to the user.
oenb_fetch <- function(url) {
  content <- tryCatch(suppressWarnings(readLines(url)),
                      error = function(e) NULL)
  if (is.null(content)) {
    message("The data web service of the OeNB could not be reached. ",
            "Please check your internet connection and try again later.")
    return(NULL)
  }

  xml <- tryCatch(XML::xmlParse(content), error = function(e) NULL)
  if (is.null(xml)) {
    message("The response of the data web service of the OeNB could not be parsed.")
    return(NULL)
  }

  # Only an 'errors' element directly below the root reports a problem with the
  # query. Anchoring the path keeps a node of that name somewhere inside a
  # regular response from being mistaken for one. An element without a message
  # is ignored, so that an empty one cannot raise an error without a reason.
  errors <- XML::xpathSApply(xml, "/*/errors", XML::xmlValue)
  errors <- gsub("\\s+", " ", trimws(unlist(errors)))
  errors <- errors[nzchar(errors)]
  if (length(errors) > 0) {
    stop("The data web service of the OeNB returned an error: ",
         paste(errors, collapse = " "), call. = FALSE)
  }

  return(xml)
}
