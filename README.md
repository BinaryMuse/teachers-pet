Teacher's Pet
=============

> A library for passing all the tests

Teacher's Pet is a small, toy testing framework created with the intent to learn how to build a testing framework. You probably shouldn't use it for real things.

Use
---

After cloning:

```
$ npm install
$ ./bin/tpet [options] [tests...]
```

`options` can be:

* `--reporter reporter` (where `reporter` is `bdd` or `dots`) - specify the reporter to use to summarize the test run
* `--async-timeout time` (where `time` is a number in milliseconds) - change the amount of time that the test runner waits before assuming an async test has failed; you can modify this on an individual `describe` or `it` basis by passing an option, e.g.

  ```coffeescript
  it 'waits longer than normal', timeout: 60000, (done) ->
    # ...
  ```

Supports JS and CoffeeScript out of the box.

Spec Descriptions
-----------------

Example:

```coffee-script
assert = require 'assert'

describe 'Basic tests', ->
  beforeEach ->
    doThing()

  afterEach ->
    tearDownThing()

  it 'tests equality', ->
    assert.equal 1, 1

  it 'tests async', (done) ->
    setTimeout done, 200

  it 'tests async with promises', ->
    return new Promise (resolve, reject) ->
      setTimeout resolve, 200
```

The following functions are made available globally:

* `describe` - set up context, useful for describing a group of tests or making them share `beforeEach`/`afterEach` hooks
* `xdescribe` - like `describe`, but mark all child tests as pending (they will be skipped)
* `fdescribe` - like `describe`, but makes tests inside focused; focused tests only run if they have as many "f"s as the other highest-used `fdescribe` or `fit` in the test suite. You can use up to six "f"s.
* `it` - create a test; throw an exception from the test function to make the test fail
* `xit` - like `it`, but mark the test as pending (it will be skipped)
* `fit` - like `it`, but makes the test focused; focused tests only run if they have as many "f"s as the other highest-used `fdescribe` or `fit` in the test suite. You can use up to six "f"s.
* `beforeEach` - run some code before each test
* `afterEach` - run some code after each test

`describe` blocks can be nested inside each other; all the hooks defined in any parent `describe`s are ran in definition order.

The functions passed to `beforeEach`, `afterEach`, and `it` blocks may take an optional `done` parameter; if the function takes such a parameter, the test is marked as async, and the done parameter *must* be called with a falsy value in order for the test to continue.

Both `describe` and `it` blocks can take an optional parameter after the description (before the callback) specifying certain options. Right now, the following are supported:

* `async: ms` - set the number of milliseconds the test runner will wait for the callback to be called
