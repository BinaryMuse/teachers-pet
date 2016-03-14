SpecSuite = require './spec-suite'

module.exports =
class SpecEnvironment
  constructor: (@reporter, @options={}) ->
    @options =
      asyncTimeout: @options.asyncTimeout ? 1000
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

  describe: (description, userOptions, subSuiteFn) =>
    @createDescribe description, userOptions, subSuiteFn, {}

  xdescribe: (description, userOptions, subSuiteFn) =>
    @createDescribe description, userOptions, subSuiteFn, pending: true

  createDescribe: (description, userOptions, subSuiteFn, options={}) ->
    if not subSuiteFn?
      subSuiteFn = userOptions
      userOptions = {}
    subSuite = @currentSuite().describe description, userOptions, subSuiteFn, options
    @pushSuite(subSuite)
    subSuiteFn.call(@userEnv)
    @popSuite()
    subSuite

  it: (description, userOptions, itFn) =>
    @createIt description, userOptions, itFn, {}

  xit: (description, userOptions, itFn) =>
    @createIt description, userOptions, itFn, pending: true

  createIt: (description, userOptions, itFn, options={}) =>
    if not itFn?
      itFn = userOptions
      userOptions = {}

    if not itFn?
      options = Object.assign {}, options, pending: true

    @currentSuite().it description, userOptions, itFn, options

  beforeEach: (beforeFn) =>
    @currentSuite().beforeEach beforeFn

  afterEach: (afterFn) =>
    @currentSuite().afterEach afterFn
