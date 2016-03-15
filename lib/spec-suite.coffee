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
    @focusLevel = @options.focusLevel ? 0

  isPending: ->
    @options.pending or @parentSuite?.isPending()

  describe: (description, userOptions, subSuiteFn, options={}) ->
    focusLevel = options.focusLevel ? 0
    focusLevel = Math.max @focusLevel, focusLevel
    options = Object.assign {}, options,
      focusLevel: focusLevel

    userOptions = Object.assign {}, @userOptions, userOptions
    subSuite = new SpecSuite(@env, description, this, userOptions, options)
    @subSuites.push(subSuite)
    subSuite

  xdescribe: (args...) ->
    @describe(args...)

  it: (description, userOptions, itFn, options={}) =>
    focusLevel = options.focusLevel ? 0
    focusLevel = Math.max @focusLevel, focusLevel
    options = Object.assign {}, options,
      focusLevel: focusLevel

    userOptions = Object.assign {}, @userOptions, userOptions
    spec = new Spec(description, itFn, this, userOptions, options)
    @specs.push(spec)
    spec

  xit: (args...) ->
    @it(args..., true)

  beforeEach: (beforeFn) =>
    @hooks.beforeEach.push beforeFn

  afterEach: (afterFn) =>
    @hooks.afterEach.push afterFn
