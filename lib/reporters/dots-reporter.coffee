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
    lines = spec.exception.stack.trim().split("\n")
    for line in lines
      console.log '  ', line
    console.log ''

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
