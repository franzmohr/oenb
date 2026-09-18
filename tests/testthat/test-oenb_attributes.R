test_that("oenb_attributes parses a recorded response", {
  local_fixture("attributes.xml")
  result <- oenb_attributes(id = "11", pos = "VDBFKBSC217000")

  expect_s3_class(result, "data.frame")
  expect_identical(names(result),
                   c("attribute_code", "attribute", "value_code", "value"))
  expect_gt(nrow(result), 0)
  expect_true(all(grepl("^dval[0-9]+$", result$attribute_code)))
  expect_false(any(is.na(result$attribute)))
})

test_that("oenb_attributes returns an empty result when there are no attributes", {
  local_fixture("data_empty.xml")
  expect_message(result <- oenb_attributes(id = "11", pos = "X"),
                 "No attributes were found")
  expect_identical(nrow(result), 0L)
  expect_identical(names(result),
                   c("attribute_code", "attribute", "value_code", "value"))
})

test_that("oenb_attributes returns NULL when the web service is unavailable", {
  local_fixture(NULL)
  expect_message(result <- oenb_attributes(id = "11", pos = "X"),
                 "could not be reached")
  expect_null(result)
})

test_that("oenb_attributes encodes its arguments", {
  env <- new.env()
  local_url_recorder(env)
  oenb_attributes(id = "11", pos = "A B")
  expect_identical(
    get("requested_url", envir = env),
    "https://www.oenb.at/isadataservice/content?lang=EN&hierid=11&pos=A%20B")
})
