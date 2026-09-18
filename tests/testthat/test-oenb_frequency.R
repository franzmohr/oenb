test_that("oenb_frequency parses a recorded response", {
  local_fixture("frequency.xml")
  result <- oenb_frequency(id = "11", pos = "VDBFKBSC217000")

  expect_s3_class(result, "data.frame")
  expect_identical(names(result), c("frequency", "available_period"))
  expect_gt(nrow(result), 0)
  expect_type(result$frequency, "character")
  expect_type(result$available_period, "character")
  expect_true(all(result$frequency %in% c("D", "M", "Q", "H", "A")))
})

test_that("oenb_frequency returns an empty result when no frequency is returned", {
  local_fixture("data_empty.xml")
  expect_message(result <- oenb_frequency(id = "11", pos = "X"),
                 "No frequencies were found")
  expect_identical(nrow(result), 0L)
  expect_identical(names(result), c("frequency", "available_period"))
})

test_that("oenb_frequency returns NULL when the web service is unavailable", {
  local_fixture(NULL)
  expect_message(result <- oenb_frequency(id = "11", pos = "X"),
                 "could not be reached")
  expect_null(result)
})

test_that("oenb_frequency requests the datafrequency endpoint", {
  env <- new.env()
  local_url_recorder(env)
  oenb_frequency(id = "11", pos = "VDBFKBSC217000")
  expect_identical(
    get("requested_url", envir = env),
    paste0("https://www.oenb.at/isadataservice/datafrequency?lang=EN",
           "&hierid=11&pos=VDBFKBSC217000"))
})
