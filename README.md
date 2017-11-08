# Testium [![travis-ci build](https://travis-ci.org/groupon/testium.svg?branch=master)](https://travis-ci.org/groupon/testium)

Testium is a testing library focused on providing a simple,
but effective,
tool for testing your web applications
in different browsers (via Selenium)
and headlessly (via PhantomJS).

## Usage

This particular module bundles a few different testium libraries together in a fashion
that is no longer recommended.  Please instead use a testing interface modules + one
of the testium drivers, e.g:

https://github.com/testiumjs/testium-mocha and https://github.com/testiumjs/testium-driver-wd

```
$ npm install --save-dev testium-mocha testium-driver-wd
```

```javascript
const { browser } = require('testium-mocha');

describe('something', () => {
  before(browser.beforeHook({ driver: 'wd' }));

  it('works', () => browser.loadPage('/'));
});
```

## API Docs

For full API documentation, see the [Testium API Docs](http://testiumjs.com/api/)
