Spec = require './spec'

module.exports =
class SpecSuite
  constructor: (@env, @description, @parentSuite, @options={}) ->
    @hooks =
      before: []
      beforeEach: []
      after: []
      afterEach: []
    @specs = []
    @subSuites = []

  isPending: ->
    @options.pending or @parentSuite?.isPending()

  describe: (description, subSuiteFn, options={}) ->
    subSuite = new SpecSuite(@env, description, this, options)
    @subSuites.push(subSuite)
    subSuite

  xdescribe: (args...) ->
    @describe(args...)

  it: (description, itFn, options={}) =>
    spec = new Spec(description, itFn, this, options)
    @specs.push(spec)
    spec

  xit: (args...) ->
    @it(args..., true)

  beforeEach: (beforeFn) ->
    @hooks.beforeEach.push beforeFn

  afterEach: (afterFn) ->
    @hooks.afterEach.push afterFn
