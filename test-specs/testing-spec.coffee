assert = require 'assert'

beforeEachCount = 0
afterEachCount = 0

describe 'Basic tests', ->
  beforeEach ->
    beforeEachCount += 1
    @value = 10

  it 'tests things successfully', ->
    assert.equal true, true

  it 'tests other things', ->
    assert.equal 1, 1

  it 'allows setting on the user env', ->
    assert.equal @value, 10

  describe 'nested tests\' beforeEach\'s', ->
    beforeEach ->
      @value += 10

    it 'works as expected', ->
      assert.equal @value, 20

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

  describe 'xits', ->
    xit 'marks a spec as pending', ->

    it 'allows other specs at the same level to run', ->
