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

  describe 'hooks with errors', ->
    beforeEach ->
      throw new Error('Purposeful beforeEach error')

    it 'makes the associated tests fail (this should fail)', ->

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

  describe 'async testing', ->
    beforeEach (done) ->
      setTimeout =>
        @val = 100
        done()
      , 200

    it 'waits for async hooks', ->
      assert.equal @val, 100

    it 'works', (done) ->
      setTimeout done, 200

    it 'times out (this should fail)', (done) ->
      setTimeout done, 1200

    it 'allows overriding the timeout', timeout: 1500, (done) ->
      setTimeout done, 1200

    it 'fails when passing a value to done (this should fail)', (done) ->
      setTimeout (-> done(new Error('omg'))), 100

    it 'waits for a promise', ->
      return new Promise (res, rej) ->
        setTimeout (-> res()), 200

    it 'fails when a promise is rejected (this should fail)', ->
      try
        return new Promise (res, rej) ->
          throw new Error("thrown from promise")
      catch e
        console.log "I got a thing!"

    # It seems Node hooks into setTimeout (and others) to catch exceptions
    # thrown and turns them into uncaughtException events on `process`. However,
    # we can't assume that such evets came from the spec, as they might have
    # come from other background timers. Domains might be an answer, but they
    # are fully deprecated according to the docs. Just commenting this out for now.
    #
    # it 'fails when a promise is rejected (this should fail 2)', ->
    #   try
    #     return new Promise (res, rej) ->
    #       setTimeout ->
    #         throw new Error("thrown from promise 2")
    #       , 200
    #   catch e
    #     console.log "I got a thing!"

    it 'only waits the timeout to pass with promises (this should fail)', ->
      return new Promise (res, rej) ->
        setTimeout (-> res()), 1200
