SpecSuite = require './spec-suite'

module.exports =
class SpecEnvironment
  constructor: (@reporter) ->
    @userEnv = {}
    @highestFocusLevel = 0
    @rootSuite = new SpecSuite(this, '<root>')
    @suiteStack = [@rootSuite]

  currentSuite: =>
    @suiteStack[@suiteStack.length - 1]

  pushSuite: (suite) =>
    @suiteStack.push(suite)

  popSuite: =>
    @suiteStack.pop()

  describe: (description, subSuiteFn, options={}) =>
    subSuite = @currentSuite().describe description, subSuiteFn, options
    @pushSuite(subSuite)
    subSuiteFn.call(@userEnv)
    @popSuite()
    subSuite

  xdescribe: (args...) =>
    @describe args..., pending: true

  it: (description, itFn, options={}) =>
    if not itFn?
      options = Object.assign {}, options, pending: true
    @currentSuite().it description, itFn, options

  xit: (args...) =>
    @it args..., pending: true

  beforeEach: (beforeFn) =>
    @currentSuite().beforeEach beforeFn

  afterEach: (afterFn) =>
    @currentSuite().afterEach afterFn
