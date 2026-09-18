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

test_that("oenb_frequency reports every frequency of a series only once", {
  # The service repeats the frequency of a series once per combination of its
  # attributes, which produced thousands of identical rows for some series.
  # Removing the repetition must not remove genuinely different rows.
  local_fixture("frequency_repeated.xml")
  result <- oenb_frequency(id = "100140002", pos = "VDBMSKREDITE")

  expect_identical(anyDuplicated(result), 0L)
  expect_identical(nrow(result), nrow(unique(result)))

  # the recorded response holds seven different frequency and period pairs
  expect_identical(nrow(result), 7L)
  expect_true(all(c("M", "A") %in% result$frequency))
  expect_identical(names(result), c("frequency", "available_period"))
  expect_identical(row.names(result), as.character(seq_len(nrow(result))))
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
  expect_silent(result <- oenb_frequency(id = "11", pos = "X"))
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
