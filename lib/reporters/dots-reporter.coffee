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
  onSuiteEnd: (suite) =>

  onSpecEnd: (spec, status) =>
    @specCount += 1
    if status is "pass"
      @passCount += 1
      process.stdout.write '.'.green
    else if status is "skip"
      @pendingCount += 1
      process.stdout.write '-'.yellow
    else if status is "fail"
      @failures.push(spec)
      process.stdout.write 'F'.red
    else
      process.stdout.write '?'
