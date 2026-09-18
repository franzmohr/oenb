test_that("oenb_check_lang accepts the supported languages", {
  expect_null(oenb:::oenb_check_lang("EN"))
  expect_null(oenb:::oenb_check_lang("DE"))
})

test_that("oenb_check_lang rejects unsupported input", {
  expect_error(oenb:::oenb_check_lang("FR"), "not supported")
  expect_error(oenb:::oenb_check_lang("en"), "not supported")
  expect_error(oenb:::oenb_check_lang(NA), "not supported")
  expect_error(oenb:::oenb_check_lang(NULL), "not supported")
  expect_error(oenb:::oenb_check_lang(c("EN", "DE")), "not supported")
})

test_that("every exported function validates the language", {
  expect_error(oenb_toc(lang = "FR"), "not supported")
  expect_error(oenb_dataset(id = "11", lang = "FR"), "not supported")
  expect_error(oenb_attributes(id = "11", pos = "X", lang = "FR"), "not supported")
  expect_error(oenb_frequency(id = "11", pos = "X", lang = "FR"), "not supported")
  expect_error(oenb_metadata(id = "11", pos = "X", lang = "FR"), "not supported")
  expect_error(oenb_data(id = "11", pos = "X", lang = "FR"), "not supported")
})

test_that("oenb_encode percent-encodes reserved characters", {
  expect_identical(oenb:::oenb_encode("11"), "11")
  expect_identical(oenb:::oenb_encode("2019-11"), "2019-11")
  expect_identical(oenb:::oenb_encode("VDBFKBSC217000"), "VDBFKBSC217000")
  expect_identical(oenb:::oenb_encode("11 & 12"), "11%20%26%2012")
  expect_identical(oenb:::oenb_encode(c("a b", "c&d")), c("a%20b", "c%26d"))
})

test_that("oenb_empty returns a zero row data frame with the given columns", {
  result <- oenb:::oenb_empty(c("a", "b"))
  expect_s3_class(result, "data.frame")
  expect_identical(nrow(result), 0L)
  expect_identical(names(result), c("a", "b"))
})

test_that("oenb_fetch passes on an error reported by the web service", {
  expect_error(oenb:::oenb_fetch(fixture_path("error.xml")),
               "Wrong Value for param")
})

test_that("oenb_fetch fails gracefully when the service cannot be reached", {
  url <- "https://www.oenb-unreachable.invalid/isadataservice/content?lang=EN"
  expect_message(result <- oenb:::oenb_fetch(url), "could not be reached")
  expect_null(result)
})

test_that("oenb_fetch parses a valid response", {
  expect_s3_class(oenb:::oenb_fetch(fixture_path("toc.xml")), "XMLInternalDocument")
})
