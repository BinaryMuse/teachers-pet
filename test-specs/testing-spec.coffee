assert = require 'assert'

beforeEachCount = 0
afterEachCount = 0

describe 'Basic tests', ->
  beforeEach ->
    beforeEachCount += 1
    @value = []

  it 'tests things successfully', ->
    assert.equal true, true

  it 'tests other things', ->
    assert.equal 1, 1

  it 'allows setting on the user env', ->
    assert.deepEqual @value, []

  describe 'nested tests\' (multiple) beforeEach\'s', ->
    beforeEach ->
      @value.push('one')

    it 'works as expected and in order', ->
      assert.deepEqual @value, ['one', 'two']

    beforeEach ->
      @value.push('two')

  afterEach ->
    afterEachCount += 1

describe 'Other things', ->
  it 'sometimes fails (this should fail)', ->
    assert.equal 2, 3

  it 'doesn\'t carry user env over', ->
    assert.equal @value, null

  it 'allowed beforeEach and afterEach to run correctly', ->
    assert.equal beforeEachCount, 4
    assert.equal afterEachCount, 4

  describe 'an it with no callback', ->
    it 'is marked as pending'

  describe 'in nested describes', ->
    it 'reports failures at the right indent (this should fail)', ->
      assert.equal 'yep', 'nope'

    describe 'even at crazy levels', ->
      it 'still works well', ->
        assert.equal 'yep', 'yep'

  xdescribe 'xdescribes', ->
    it 'reports sub specs as pending', ->
      console.log "RUNNING THE XDESC"

    it 'reports multiple sub specs as pending', ->

    describe 'even in non-xdescribe children', ->
      it 'they are still pending', ->

  describe 'xits', ->
    xit 'marks a spec as pending', ->

    it 'allows other specs at the same level to run', ->
