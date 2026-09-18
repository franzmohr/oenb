# Helpers for testing against recorded responses of the OeNB's data web service.
#
# The fixtures in 'fixtures/' are verbatim responses of the web service. Using
# them keeps the test suite independent of an internet connection and makes a
# future change of the service's output format visible as a failing test.

fixture_path <- function(file) {
  testthat::test_path("fixtures", file)
}

# Parse a recorded response the same way oenb_fetch() would.
fixture_xml <- function(file) {
  XML::xmlParse(readLines(fixture_path(file), warn = FALSE))
}

# Make oenb_fetch() return a recorded response for the remainder of a test, so
# that the parsing code of the exported functions can be tested without network
# access. Use file = NULL to simulate an unavailable web service.
#
# The replacement returns NULL without a message. The message itself belongs to
# oenb_fetch() and is asserted in test-utils.R; emitting it here as well would
# only test this helper.
local_fixture <- function(file, env = parent.frame()) {
  fake <- function(url) {
    if (is.null(file)) {
      return(NULL)
    }
    fixture_xml(file)
  }
  testthat::local_mocked_bindings(oenb_fetch = fake, .package = "oenb",
                                  .env = env)
}

# Record the URL that a function under test requests, without contacting the
# web service.
local_url_recorder <- function(target, env = parent.frame()) {
  fake <- function(url) {
    assign("requested_url", url, envir = target)
    NULL
  }
  testthat::local_mocked_bindings(oenb_fetch = fake, .package = "oenb",
                                  .env = env)
}
