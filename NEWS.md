# oenb 0.1.0

## Bug fixes

* The check of the `lang` argument never had any effect, so that an unsupported
language was silently passed on to the web service. All functions now raise an
error for anything other than `"DE"` and `"EN"`.
* `oenb_data` failed with `object 'temp_pos' not found` whenever a query did not
return any data, for example for a valid series outside its available period.
It now returns `NULL` with an informative message.
* Arguments are percent-encoded before they are inserted into a query, so that
values containing reserved characters no longer produce a malformed URL.

## Improvements

* All functions now fail gracefully with an informative message and return
`NULL` if the web service cannot be reached, as required by the CRAN policy on
packages that use internet resources.
* Error messages of the web service, for example about an unknown position code,
are passed on to the user instead of surfacing as internal errors such as
`subscript out of bounds`.
* Queries that return no match now yield an empty data frame with the documented
columns instead of failing.
* Added a test suite based on recorded responses of the web service, so that the
package can be tested without an internet connection.

## Other changes

* The minimum required R version is now 4.1.0, which is the version required by
the imported package `dplyr`.

# oenb 0.0.2

* Added a `NEWS.md` file to track changes to the package.
* Adapted `oenb_data` to deal with a recent change of the API output
