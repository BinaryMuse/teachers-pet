Spec = require './spec'

module.exports =
class SpecSuite
  constructor: (@env, @description, @parentSuite, @userOptions, @options={}) ->
    @hooks =
      before: []
      beforeEach: []
      after: []
      afterEach: []
    @specs = []
    @subSuites = []

  isPending: ->
    @options.pending or @parentSuite?.isPending()

  describe: (description, userOptions, subSuiteFn, options={}) ->
    inheritedUserOptions = Object.assign {}, @userOptions, userOptions
    subSuite = new SpecSuite(@env, description, this, inheritedUserOptions, options)
    @subSuites.push(subSuite)
    subSuite

  xdescribe: (args...) ->
    @describe(args...)

  it: (description, userOptions, itFn, options={}) =>
    inheritedUserOptions = Object.assign {}, @userOptions, userOptions
    spec = new Spec(description, itFn, this, inheritedUserOptions, options)
    @specs.push(spec)
    spec

  xit: (args...) ->
    @it(args..., true)

  beforeEach: (beforeFn) =>
    @hooks.beforeEach.push beforeFn

  afterEach: (afterFn) =>
    @hooks.afterEach.push afterFn
