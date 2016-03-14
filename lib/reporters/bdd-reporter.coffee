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
    @level = -1
    @specCount = 0
    @passCount = 0
    @pendingCount = 0
    @failures = []

  report: (env) ->
    console.log ''
    @reportCounts()
    console.log ''
    console.log ''
    @summarizeFailures()

    if @failures.length then 1 else 0

  reportCounts: ->
    process.stdout.write " #{@specCount} specs,"
    process.stdout.write " #{@passCount} passed,"
    process.stdout.write " #{@failures.length} failed,"
    process.stdout.write " #{@pendingCount} pending"

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

  onSuiteStart: (suite) =>
    # don't output the name of the root suite
    if suite.parentSuite
      @level += 1
      writeSpaces @level, 2
      console.log suite.description

  onSuiteEnd: (suite) =>
    @level -= 1

  onSpecStart: (spec) =>
    writeSpaces @level + 1, 2
    process.stdout.write "  #{spec.description}"

  onSpecEnd: (spec, status) =>
    @specCount += 1
    color = (str) -> str

    process.stdout.clearLine()
    process.stdout.cursorTo(0)
    writeSpaces @level + 1, 2
    if status is "pass"
      color = colors.green
      @passCount += 1
      process.stdout.write "\u2713".green.bold
    else if status is "skip"
      color = colors.yellow
      @pendingCount += 1
      process.stdout.write "-".yellow.bold
    else if status is "fail"
      color = colors.red
      @failures.push(spec)
      process.stdout.write "\u2717".red.bold
    else
      process.stdout.write '?'
    process.stdout.write color(" #{spec.description}")
    console.log ''
