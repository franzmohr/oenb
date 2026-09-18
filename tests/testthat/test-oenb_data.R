test_that("oenb_data parses a recorded response", {
  local_fixture("data.xml")
  result <- oenb_data(id = "11", pos = "VDBFKBSC217000", freq = "M",
                      attr = c("dval1" = "AT"),
                      starttime = "2019-11", endtime = "2019-12")

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
  expect_true(all(c("period", "pos", "value") %in% names(result)))
  expect_type(result$value, "double")
  expect_false(any(is.na(result$period)))
})

test_that("oenb_data keeps period first, value last and the attributes in order", {
  local_fixture("data.xml")
  result <- oenb_data(id = "11", pos = "VDBFKBSC217000", freq = "M")

  expect_identical(names(result)[1], "period")
  expect_identical(names(result)[length(names(result))], "value")

  attr_cols <- names(result)[grepl("attr", names(result), fixed = TRUE)]
  expect_gt(length(attr_cols), 0)
  expect_identical(attr_cols, sort(attr_cols))

  # the attribute columns have to form one uninterrupted block
  attr_pos <- which(grepl("attr", names(result), fixed = TRUE))
  expect_identical(attr_pos, seq(min(attr_pos), max(attr_pos)))

  # no column is dropped or duplicated by the reordering
  expect_identical(anyDuplicated(names(result)), 0L)
})

test_that("oenb_data returns NULL instead of failing when there are no data", {
  # regression test: this used to fail with "object 'temp_pos' not found"
  local_fixture("data_empty.xml")
  expect_message(result <- oenb_data(id = "11", pos = "VDBFKBSC217000", freq = "M",
                                     starttime = "1899-01", endtime = "1899-02"),
                 "did not return any data")
  expect_null(result)
})

test_that("oenb_data returns NULL when the web service is unavailable", {
  local_fixture(NULL)
  expect_message(result <- oenb_data(id = "11", pos = "VDBFKBSC217000"),
                 "could not be reached")
  expect_null(result)
})

test_that("oenb_data builds the query from its arguments", {
  env <- new.env()
  local_url_recorder(env)

  oenb_data(id = "11", pos = "VDBFKBSC217000")
  expect_identical(
    get("requested_url", envir = env),
    "https://www.oenb.at/isadataservice/data?lang=EN&hierid=11&pos=VDBFKBSC217000")

  oenb_data(id = "11", pos = "VDBFKBSC217000", freq = "M",
            attr = c("dval1" = "AT"), starttime = "2019-11", endtime = "2019-12")
  expect_identical(
    get("requested_url", envir = env),
    paste0("https://www.oenb.at/isadataservice/data?lang=EN&hierid=11",
           "&pos=VDBFKBSC217000&freq=M&dval1=AT",
           "&starttime=2019-11&endtime=2019-12"))
})

test_that("oenb_data accepts several positions and attributes", {
  env <- new.env()
  local_url_recorder(env)

  oenb_data(id = "11", pos = c("VDBFKBSC217000", "VDBFKBSC217001"),
            attr = c("dval3" = "A", "dval5" = "I"))
  expect_identical(
    get("requested_url", envir = env),
    paste0("https://www.oenb.at/isadataservice/data?lang=EN&hierid=11",
           "&pos=VDBFKBSC217000&pos=VDBFKBSC217001&dval3=A&dval5=I"))
})

test_that("oenb_data encodes arguments that contain reserved characters", {
  env <- new.env()
  local_url_recorder(env)
  oenb_data(id = "11", pos = "A&B")
  expect_identical(
    get("requested_url", envir = env),
    "https://www.oenb.at/isadataservice/data?lang=EN&hierid=11&pos=A%26B")
})
