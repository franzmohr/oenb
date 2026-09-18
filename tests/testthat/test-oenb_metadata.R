test_that("oenb_metadata parses a recorded response", {
  local_fixture("metadata.xml")
  result <- oenb_metadata(id = "11", pos = "VDBFKBSC217000")

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("attribute", "description"))
  expect_gt(nrow(result), 0)
  expect_type(result$attribute, "character")
  expect_type(result$description, "character")
  expect_true("title" %in% result$attribute)
})

test_that("oenb_metadata handles a nested element that holds a single entry", {
  # regression test: a 'data_available' block with exactly one 'data' child is a
  # list of length one. It used to pass for a field of its own and contribute
  # the column name 'data', which made the result fail to combine with the
  # rows built before it. Roughly half of the series are affected.
  local_fixture("metadata_single.xml")
  result <- oenb_metadata(id = "18", pos = "VDBWAZ16")

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("attribute", "description"))
  expect_gt(nrow(result), 0)
  expect_type(result$description, "character")
  expect_true("title" %in% result$attribute)

  # the nested elements must not appear as fields of their own
  expect_false(any(c("data", "release") %in% names(result)))
  expect_false(any(c("data_available", "releases") %in% result$attribute))
})

test_that("oenb_metadata does not let its result overwrite the pos argument", {
  env <- new.env()
  local_url_recorder(env)
  oenb_metadata(id = "11", pos = "VDBFKBSC217000")
  expect_identical(
    get("requested_url", envir = env),
    paste0("https://www.oenb.at/isadataservice/meta?lang=EN",
           "&hierid=11&pos=VDBFKBSC217000"))
})

test_that("oenb_metadata returns an empty result when no metadata are returned", {
  local_fixture("data_empty.xml")
  expect_message(result <- oenb_metadata(id = "11", pos = "X"),
                 "No metadata were found")
  expect_identical(nrow(result), 0L)
  expect_identical(names(result), c("attribute", "description"))
})

test_that("oenb_metadata returns NULL when the web service is unavailable", {
  local_fixture(NULL)
  expect_silent(result <- oenb_metadata(id = "11", pos = "X"))
  expect_null(result)
})
