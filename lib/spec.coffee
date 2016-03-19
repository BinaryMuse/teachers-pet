module.exports =
class Spec
  # A Spec represents a single test from a user spec. It has a reference to its
  # parent SpecSuite.
  constructor: (@description, @itFn, @suite, @userOptions, @options={}) ->
    @ran = false
    @skipped = false
    @failed = false
    @passed = false
    @exception = null
    @focusLevel = @options.focusLevel ? 0

  isPending: ->
    @options.pending or @suite.isPending() or @focusLevel < @suite.env.maxFocusLevel

  pass: ->
    @ran = true
    @passed = true

  fail: (exception) ->
    @ran = true
    @failed = true
    @exception = exception

  skip: ->
    @skipped = true
