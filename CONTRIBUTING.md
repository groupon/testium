# Contribution Guide

Please follow this guide when
creating issues or pull requests.

## Reporting a Bug

Before reporting a bug,
make sure you are using the latest versions of
testium and the browsers that expose the bug.

When reporting a bug with testium,
please provide a minimal test case.
This can be a gist,
inline in the description,
or in the form of a pull request
that includes a failing test.

If you are contributing a bug fix,
make sure it has a passing test
in your pull request.

## Adding a Feature

Adding currently unimplemented WebDriver calls
will always be considered.
Eventually, testium should support
all of the WebDriver calls in some way.
In order to implement these,
you must first add them to
[webdriver-http-sync](https://github.com/groupon/webdriver-http-sync).

Before implementing features other than WebDriver calls,
try to make sure that
(1) no one else is currently working on that and
(2) you have checked with the maintainers
that this is something they would like to see.

All features should have tests.

