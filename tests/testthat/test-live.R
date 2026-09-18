# Integration tests against the live web service.
#
# These are skipped on CRAN and whenever the service cannot be reached, so that
# a failing test always points at a real change of the API rather than at a
# missing internet connection.

skip_live <- function() {
  skip_on_cran()
  skip_if_offline("www.oenb.at")
}

test_that("the live table of contents still has the expected shape", {
  skip_live()
  result <- oenb_toc()
  skip_if(is.null(result), "The OeNB web service is not available.")

  expect_identical(names(result), c("dataset_id", "description"))
  expect_gt(nrow(result), 0)
})

test_that("a live data query still has the expected shape", {
  skip_live()
  result <- oenb_data(id = "11", pos = "VDBFKBSC217000", freq = "M",
                      attr = c("dval1" = "AT"),
                      starttime = "2019-11", endtime = "2019-12")
  skip_if(is.null(result), "The OeNB web service is not available.")

  expect_identical(names(result)[1], "period")
  expect_identical(names(result)[length(names(result))], "value")
  expect_type(result$value, "double")
  expect_identical(nrow(result), 2L)
})

test_that("the live service reports an unknown position code", {
  skip_live()
  expect_error(oenb_data(id = "11", pos = "NOSUCHPOS", freq = "M"),
               "Wrong Value for param")
})
