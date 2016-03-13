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
    console.log ''
    console.log ''
    @reportCounts()
    console.log ''
    console.log ''
    @reportSuite -1, env.rootSuite
    console.log ''
    console.log ''
    @summarizeFailures()

    if @failures.length then 1 else 0

  reportSuite: (level, suite) ->
    if suite.parentSuite
      writeSpaces level, 2
      console.log suite.description

    wroteNewline = false
    for spec in suite.specs
      @reportSpec spec, level
    for subSuite in suite.subSuites
      @reportSuite level + 1, subSuite

  reportSpec: (spec, indent = 0) ->
    writeSpaces indent + 1, 2
    color = (str) -> str

    if not spec.ran
      color = colors.yellow
      process.stdout.write "-".yellow.bold
    else if spec.failed
      color = colors.red
      process.stdout.write "\u2717".red.bold
    else
      color = colors.green
      process.stdout.write "\u2713".green.bold

    process.stdout.write color(" #{spec.description}\n")

  reportCounts: ->
    process.stdout.write "#{@specCount} specs, "
    process.stdout.write "#{@passCount} passed, "
    process.stdout.write "#{@failures.length} failed, "
    process.stdout.write "#{@pendingCount} pending"

  summarizeFailures: ->
    @summarizeFailure(failure) for failure in @failures

  summarizeFailure: (spec) ->
    desc = spec.description
    suite = spec.suite
    while suite.parentSuite
      desc = suite.description + ' ' + desc
      suite = suite.parentSuite

    console.log ' ', desc.red
    lines = spec.exception.stack.split("\n")
    for line in lines
      console.log '  ', line

  onSpecPending: =>
    @specCount += 1
    @pendingCount += 1
    process.stdout.write '-'.yellow

  onSpecPass: =>
    @specCount += 1
    @passCount += 1
    process.stdout.write '.'.green

  onSpecFail: (spec) =>
    @specCount += 1
    @failures.push spec
    process.stdout.write 'F'.red
