module.exports =
class Spec
  constructor: (@description, @itFn, @suite, @pending=false) ->
    @ran = false
    @skipped = false
    @failed = false
    @exception = null

  pass: ->
    @ran = true

  fail: (exception) ->
    @ran = true
    @failed = true
    @exception = exception

  skip: ->
    @skipped = true
