## Test environments

* local Windows 11, R 4.6.1
* GitHub Actions (ubuntu-latest): R-devel (4.7.0), R-release (4.6.1),
  R-oldrel-1 (4.5.3)
* GitHub Actions (windows-latest): R-release (4.6.1)
* GitHub Actions (macos-latest): R-release (4.6.1)

## R CMD check results

0 errors | 0 warnings | 0 notes

The check returned `Status: OK` in every environment, locally with
`--as-cran --run-donttest` and on GitHub Actions in run
<https://github.com/franzmohr/oenb/actions/runs/37154117919>.

## Comments

This is a minor release. It adds a help page for the package that describes
how a query is built, documents the columns of the result of every function and
gives the messages and errors of the package classes, so that the reason for an
empty result can be told apart without matching the text of a message. The
behaviour of the functions is otherwise unchanged.

The examples of all functions access the web service and are therefore wrapped
in `\donttest{}`. They return `NULL` with a message instead of failing if the
service cannot be reached. The tests do not require an internet connection:
they run against recorded responses of the web service, and the few tests that
contact the service are skipped on CRAN.
