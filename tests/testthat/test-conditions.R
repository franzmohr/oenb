test_that("an unreachable service signals oenb_unavailable with the url", {
  url <- "https://www.oenb-unreachable.invalid/isadataservice/content?lang=EN"
  cond <- expect_message(result <- oenb:::oenb_fetch(url),
                         class = "oenb_unavailable")
  expect_s3_class(cond, "oenb_message")
  expect_identical(cond$url, url)
  expect_null(result)
})

test_that("an unparsable response signals oenb_unparsable", {
  file <- tempfile(fileext = ".xml")
  on.exit(unlink(file), add = TRUE)
  writeLines("this is not xml <", file)
  cond <- expect_message(result <- suppressWarnings(oenb:::oenb_fetch(file)),
                         class = "oenb_unparsable")
  expect_s3_class(cond, "oenb_message")
  expect_null(result)
})

test_that("an error of the service raises oenb_service_error with its message", {
  cond <- expect_error(oenb:::oenb_fetch(fixture_path("error.xml")),
                       class = "oenb_service_error")
  expect_s3_class(cond, "oenb_error")
  expect_identical(cond$url, fixture_path("error.xml"))
  expect_true(any(grepl("Wrong Value for param", cond$service_message)))
})

test_that("rejected arguments raise oenb_invalid_argument", {
  expect_error(oenb_toc(lang = "FR"), class = "oenb_invalid_argument")
  expect_error(oenb_dataset(id = NA), class = "oenb_invalid_argument")
})

test_that("queries without results signal oenb_no_results", {
  local_fixture("dataset_empty.xml")
  cond <- expect_message(result <- oenb_dataset(id = "11"),
                         class = "oenb_no_results")
  expect_s3_class(cond, "oenb_message")
  expect_match(cond$url, "hierid=11", fixed = TRUE)
  expect_identical(nrow(result), 0L)
})

test_that("oenb_data signals oenb_no_results when there are no data", {
  local_fixture("data_empty.xml")
  expect_message(result <- oenb_data(id = "11", pos = "VDBFKBSC217000"),
                 class = "oenb_no_results")
  expect_null(result)
})

test_that("the functions on a series point to oenb_dataset when nothing is found", {
  local_fixture("dataset_empty.xml")
  expect_message(oenb_attributes(id = "11", pos = "X"), "oenb_dataset()",
                 fixed = TRUE, class = "oenb_no_results")
  expect_message(oenb_frequency(id = "11", pos = "X"), "oenb_dataset()",
                 fixed = TRUE, class = "oenb_no_results")
  expect_message(oenb_metadata(id = "11", pos = "X"), "oenb_dataset()",
                 fixed = TRUE, class = "oenb_no_results")
})

test_that("the conditions can be caught by their class", {
  local_fixture("data_empty.xml")
  reason <- NULL
  withCallingHandlers(
    oenb_data(id = "11", pos = "VDBFKBSC217000"),
    oenb_no_results = function(m) {
      reason <<- "no_results"
      invokeRestart("muffleMessage")
    })
  expect_identical(reason, "no_results")
})
