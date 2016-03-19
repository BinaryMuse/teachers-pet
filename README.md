Teacher's Pet 🍎
===============

> A library for passing all the tests

Teacher's Pet is a small, toy testing framework created with the intent to learn how to build a testing framework. You probably shouldn't use it for real things.

Installation
------------

Currently Teacher's Pet isn't available on npm. Install it from source by cloning the repo, and then running (inside the cloned directory):

```
$ npm install
```

Usage
-----

```
Usage: bin/tpet [options] [test files...]

Options:
  -t, --async-timeout  how long to wait (in ms) for async tests to finish
                                                                 [default: 1000]
  -o, --reporter       which test reporter to use
                                      [choices: "dots", "bdd"] [default: "dots"]
  -h, --help           Show help                                       [boolean]
```

API
---

#### Creating Test Suites

You can create test suites by utilizing several globals that Teacher's Pet makes available. JavaScript and CoffeeScript are supported out of the box.

 * ##### `describe`

 Create a new suite inside the current suite. Suites are useful for grouping tests together and for sharing data by utilizing the same hooks. A suite nested in other suites runs all the hooks from all its parent suites (in order from outermost to innermost).

 * ##### `it`

 Create a new test inside the current suite. To make a test fail, simply throw an error inside it (or use async tests; see more below).

 * ##### `xdescribe` / `xit`

 Just like `describe` and `it`, except that the created suite or test is marked as pending. Pending tests are skipped, and pending suites make all their included tests and sub-suites pending.

 * ##### `fdescribe` / `fit`

 Just like `describe` and `it`, except that the created suite or test is focused. You can use between one and six `f`s at the beginning of the call (e.g. `ffffffdescribe` and `ffffffit`); the number of `f`s corresponds to the focus level of the suite or test. When running your tests, Teacher's Pet will only run the tests equal to the highest focus level of all the tests.

 * ##### `beforeEach` / `afterEach`

 Creates a hook in the current suite that runs before or after every test in the suite (and any nested suites). Useful for setting up shared data or priming an environment for testing, or tearing down any external resources after tests finish.

 If `beforeEach` or `afterEach` throws an error, the test will fail. If a hook or test fails, any later hooks (and the test itself, in the case of `beforeEach`) will not be ran. # TODO: should we always run afterEach

Simple example:

```javascript
var assert = require('assert') // use whatever assertion lib you like!

describe('My test suite', function() {
  it('tests things', function() {
    assert.equal(1, 1)
  })

  describe('with sub-suites', function() {
    var value = null

    beforeEach(function() {
      value = 10
    })

    it('runs the sub-suites too', function() {
      assert.ok(true)
    })

    it('runs beforeEach before every test', function() {
      assert.equal(value, 10)
    })
  })
})
```

##### Options to `describe` and `it` (and variants)

`describe` and `it` (and their variants) can optionally take an object parameter between the description and the callback function that specifies various options. The options are:

 * `timeout`

 Specifies the amount of time in milliseconds to wait for the async tests to finish before it fails automatically. Overrides the `--async-timeout` command line option.

  ```coffeescript
  it 'waits longer than normal', timeout: 60000, (done) ->
    # ...
  ```
