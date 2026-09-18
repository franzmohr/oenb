test_that("oenb_toc parses a recorded response", {
  local_fixture("toc.xml")
  result <- oenb_toc()

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("dataset_id", "description"))
  expect_gt(nrow(result), 0)
  expect_type(result$dataset_id, "character")
  expect_type(result$description, "character")
  expect_false(any(is.na(result$dataset_id)))
  expect_true("11" %in% result$dataset_id)
})

test_that("oenb_toc returns an empty result when no data sets are returned", {
  local_fixture("data_empty.xml")
  expect_message(result <- oenb_toc(), "did not return any data sets")
  expect_identical(nrow(result), 0L)
  expect_identical(names(result), c("dataset_id", "description"))
})

test_that("oenb_toc returns NULL when the web service is unavailable", {
  local_fixture(NULL)
  expect_silent(result <- oenb_toc())
  expect_null(result)
})

test_that("oenb_toc requests the expected URL", {
  env <- new.env()
  local_url_recorder(env)
  oenb_toc()
  expect_identical(get("requested_url", envir = env),
                   "https://www.oenb.at/isadataservice/content?lang=EN")
  oenb_toc(lang = "DE")
  expect_identical(get("requested_url", envir = env),
                   "https://www.oenb.at/isadataservice/content?lang=DE")
})
