# oenb 0.1.0

## Bug fixes

* The check of the `lang` argument never had any effect, so that an unsupported
language was silently passed on to the web service. All functions now raise an
error for anything other than `"DE"` and `"EN"`.
* `oenb_data` failed with `object 'temp_pos' not found` whenever a query did not
return any data, for example for a valid series outside its available period.
It now returns `NULL` with an informative message.
* `oenb_metadata` failed with `names do not match previous names` for every
indicator whose metadata contain a nested element that holds a single entry,
such as a `data_available` block that describes one period. In a sample of the
available series roughly four out of ten were affected. Nested elements are now
skipped consistently, whether they hold one entry or several.
* `oenb_data` arranged the attribute columns by sorting their names, so for an
indicator with ten or more attributes `attr10` was placed between `attr1` and
`attr2` and an attribute was separated from the column describing it. The value
under each column name was always correct, so code that selects columns by name
was not affected; only code that relies on their position was. The columns are
now arranged by number.
* `oenb_frequency` reports which frequencies can be chosen for a series, but
listed every one of them once per combination of the attributes of that series,
because that is how the web service reports them. For some indicators this
returned tens of thousands of entries, in one case 28512 of them for three
frequencies. Every choice is now listed once, as `oenb_attributes` already
listed the values of an attribute once. Frequencies that differ are kept, and
indicators that were not affected return what they returned before.
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
* Added a citation file, so that `citation("oenb")` returns a reference for the
package instead of one generated from the description.

# oenb 0.0.2

* Added a `NEWS.md` file to track changes to the package.
* Adapted `oenb_data` to deal with a recent change of the API output
