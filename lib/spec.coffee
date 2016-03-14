module.exports =
class Spec
  constructor: (@description, @itFn, @suite, @userOptions, @options={}) ->
    @ran = false
    @skipped = false
    @failed = false
    @passed = false
    @exception = null

  isPending: ->
    @options.pending or @suite.isPending()

  pass: ->
    @ran = true
    @passed = true

  fail: (exception) ->
    @ran = true
    @failed = true
    @exception = exception

  skip: ->
    @skipped = true
