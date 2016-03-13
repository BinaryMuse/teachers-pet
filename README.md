Teacher's Pet
=============

> A library for passing all the tests

Teacher's Pet is a small, toy testing framework created with the intention to learn how to build a testing framework. You probably shouldn't use it for real things.

Use
---

After cloning:

```
$ npm install
$ ./bin/tpet path/to/tests.ext
```

Supports JS and CoffeeScript out of the box.

Spec Descriptions
-----------------

The following functions are made available globally:

* `describe` - set up context, useful for describing a group of tests or making them share `beforeEach`/`afterEach` hooks
* `it` - create a test; throw an exception from the test function to make the test fail
* `beforeEach` - run some code before each test
* `afterEach` - run some code after each test

`describe` blocks can be nested inside each other; all the hooks defined in any parent `describe`s are ran in order.

```coffee-script
assert = require 'assert'

describe 'Basic tests', ->
  beforeEach ->
    doThing()

  it 'tests equality', ->
    assert.equal 1, 1

  afterEach ->
    tearDownThing()
```
