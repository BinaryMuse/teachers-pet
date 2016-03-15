assert = require 'assert'

describe 'Basic tests', ->
  beforeEach ->
    @value = []

  beforeEach ->
    @value.push 'asdf'

  it 'tests things successfully', ->
    assert.equal true, true

  it 'allows setting on the user env', ->
    assert.deepEqual @value, ['asdf']
