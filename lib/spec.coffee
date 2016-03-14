module.exports =
class Spec
  constructor: (@description, @itFn, @suite, @options={}) ->
    @ran = false
    @skipped = false
    @failed = false
    @exception = null

  isPending: ->
    @options.pending or @suite.isPending()

  pass: ->
    @ran = true

  fail: (exception) ->
    @ran = true
    @failed = true
    @exception = exception

  skip: ->
    @skipped = true
