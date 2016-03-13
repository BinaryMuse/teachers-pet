Spec = require './spec'

module.exports =
class SpecSuite
  constructor: (@env, @description, @parentSuite, @pending) ->
    @hooks =
      before: []
      beforeEach: []
      after: []
      afterEach: []
    @specs = []
    @subSuites = []

  describe: (description, subSuiteFn, pending=false) ->
    subSuite = new SpecSuite(@env, description, this, pending)
    @subSuites.push(subSuite)
    subSuite

  xdescribe: (args...) ->
    @describe(args...)

  it: (description, itFn, pending=false) =>
    spec = new Spec(description, itFn, this, pending or @pending)
    @specs.push(spec)
    spec

  xit: (args...) ->
    @it(args..., true)

  beforeEach: (beforeFn) ->
    @hooks.beforeEach.push beforeFn

  afterEach: (afterFn) ->
    @hooks.afterEach.push afterFn
