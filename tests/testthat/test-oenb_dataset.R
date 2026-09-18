test_that("oenb_dataset parses a recorded response", {
  local_fixture("dataset.xml")
  result <- oenb_dataset(id = "11")

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("position_code", "description"))
  expect_gt(nrow(result), 0)
  expect_type(result$position_code, "character")
  expect_type(result$description, "character")
  expect_true("VDBFKBSC217000" %in% result$position_code)
})

test_that("oenb_dataset returns an empty result for an unknown data set", {
  local_fixture("dataset_empty.xml")
  expect_message(result <- oenb_dataset(id = "999999"), "No indicators were found")
  expect_identical(nrow(result), 0L)
  expect_identical(names(result), c("position_code", "description"))
})

test_that("oenb_dataset returns NULL when the web service is unavailable", {
  local_fixture(NULL)
  expect_silent(result <- oenb_dataset(id = "11"))
  expect_null(result)
})

test_that("oenb_dataset encodes the data set ID", {
  env <- new.env()
  local_url_recorder(env)
  oenb_dataset(id = "11 & 12")
  expect_identical(get("requested_url", envir = env),
                   "https://www.oenb.at/isadataservice/content?lang=EN&hierid=11%20%26%2012")
})
