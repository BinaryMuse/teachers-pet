module.exports =
class Spec
  constructor: (@description, @itFn, @suite, @pending=false) ->
    @ran = false
    @failed = false
    @exception = null

  run: (userEnv) ->
    if @pending
      try
        @suite.env.onSpecPending(this)
      finally
        return

    @ran = true
    try
      @runHooks('beforeEach', userEnv)
      @itFn.call(userEnv)
      @runHooks('afterEach', userEnv)
      try
        @suite.env.onSpecPass(this)
      finally
        # nothing
    catch ex
      @failed = true
      @exception = ex
      try
        @suite.env.onSpecFail(this)
      finally
        # nothing

  runHooks: (hookType, userEnv) ->
    hooks = []
    suite = @suite
    while suite?
      for hook in suite.hooks[hookType]
        hooks.unshift(hook)
      suite = suite.parentSuite

    for hook in hooks
      hook.call(userEnv)
