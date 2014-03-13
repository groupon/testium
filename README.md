# selenium-download

This module allows you
to download the latest versions
of the selenium standalone server
and the chromedriver.

Keep up to date with changes
by checking the
[releases](https://github.com/groupon-testium/selenium-download/releases).

## example

```coffee
selenium = require 'selenium-download'

selenium.ensure "#{__dirname}/bin", (error) ->
  console.error error.stack if error?
  process.exit(0)
```

## api

### selenium.ensure

`ensure` ensures that
the selenium.jar and chromedriver
files are in the path provided.

If they are not,
the latest versions of both
are downloaded into that path.

### selenium.update

`update` forces
the selenium.jar and chromedriver
files to be the latest available versions.

