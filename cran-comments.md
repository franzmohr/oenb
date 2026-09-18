## Test environments

* local Windows 11, R 4.6.1
* GitHub Actions (ubuntu-latest): R-devel, R-release, R-oldrel-1
* GitHub Actions (windows-latest): R-release
* GitHub Actions (macos-latest): R-release

## R CMD check results

0 errors | 0 warnings | 0 notes

## Comments

This is a maintenance release. It fixes an error that occurred when a query did
not return any data and makes the package fail gracefully with an informative
message when the web service of the Oesterreichische Nationalbank is not
available, as required by the CRAN policy on packages that use internet
resources.

The examples of all functions access the web service and are therefore wrapped
in `\donttest{}`. They return `NULL` with a message instead of failing if the
service cannot be reached. The tests do not require an internet connection:
they run against recorded responses of the web service, and the few tests that
contact the service are skipped on CRAN.
