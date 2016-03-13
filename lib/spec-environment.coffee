SpecSuite = require './spec-suite'

module.exports =
class SpecEnvironment
  constructor: (@reporter) ->
    @userEnv = {}
    @highestFocusLevel = 0
    @rootSuite = new SpecSuite(this, '<root>')
    @currentSuite = @rootSuite

  run: ->
    @rootSuite.run(@userEnv)

  describe: (description, subSuiteFn, pending=false) =>
    currentSuite = @currentSuite
    subSuite = currentSuite.describe description, subSuiteFn, pending
    @currentSuite = subSuite
    subSuiteFn.call(@userEnv)
    @currentSuite = currentSuite
    subSuite

  xdescribe: (args...) =>
    @describe args..., true

  it: (description, itFn, pending=false) =>
    @currentSuite.it description, itFn, pending

  xit: (args...) =>
    @it args..., true

  beforeEach: (beforeFn) =>
    @currentSuite.beforeEach beforeFn

  afterEach: (afterFn) =>
    @currentSuite.afterEach afterFn

  report: ->
    @reporter.report(this)

  onSpecPending: (spec) ->
    @reporter.onSpecPending?(spec)

  onSpecPass: (spec) ->
    @reporter.onSpecPass?(spec)

  onSpecFail: (spec) ->
    @reporter.onSpecFail?(spec)
