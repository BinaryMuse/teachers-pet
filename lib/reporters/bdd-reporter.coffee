colors = require 'colors'

addSpace = (str) -> str + ' '

writeSpaces = (num, per = 1) ->
  return if num <= 0

  whitespace = [0...per].reduce(addSpace, '')
  for n in [0...num]
    process.stdout.write whitespace

module.exports =
class SpecReporter
  constructor: ->
    @specCount = 0
    @passCount = 0
    @pendingCount = 0
    @failures = []

  report: (env) ->
    @reportSuite env.rootSuite
    console.log ''
    @reportCounts()
    console.log ''
    console.log ''
    @summarizeFailures()

    if @failures.length then 1 else 0

  reportSuite: (suite, level = -1) ->
    # don't output the name of the root suite
    if suite.parentSuite
      writeSpaces level, 2
      console.log suite.description

    for spec in suite.specs
      @reportSpec spec, level
    for subSuite in suite.subSuites
      @reportSuite subSuite, level + 1

  reportSpec: (spec, indent = 0) ->
    writeSpaces indent + 1, 2
    color = (str) -> str

    if spec.skipped
      color = colors.yellow
      process.stdout.write "-".yellow.bold
    else if spec.failed
      color = colors.red
      process.stdout.write "\u2717".red.bold
    else if spec.passed
      color = colors.green
      process.stdout.write "\u2713".green.bold
    else
      process.stdout.write "?"

    process.stdout.write color(" #{spec.description}\n")

  reportCounts: ->
    process.stdout.write " #{@specCount} specs,"
    process.stdout.write " #{@passCount} passed,"
    process.stdout.write " #{@failures.length} failed,"
    process.stdout.write " #{@pendingCount} pendin"

  summarizeFailures: ->
    @summarizeFailure(failure) for failure in @failures

  summarizeFailure: (spec) ->
    desc = spec.description
    suite = spec.suite
    while suite.parentSuite
      desc = suite.description + ' ' + desc
      suite = suite.parentSuite

    console.log ' ', desc.red
    msg = spec.exception.stack ? spec.exception.message ? spec.exception
    lines = msg.trim().split("\n")
    for line in lines
      console.log '  ', line
    console.log ''

  onSpecPending: =>
    @specCount += 1
    @pendingCount += 1

  onSpecPass: =>
    @specCount += 1
    @passCount += 1

  onSpecFail: (spec) =>
    @specCount += 1
    @failures.push spec
