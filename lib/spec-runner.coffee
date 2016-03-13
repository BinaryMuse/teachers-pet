module.exports =
class SpecRunner
  constructor: (@env) ->
    @anyFailed = false

  run: ->
    suite = @env.rootSuite
    userEnv = @env.userEnv
    @runSuite(suite, userEnv)

    if @anyFailed then 1 else 0

  runSuite: (suite, userEnv) ->
    copyEnv = -> Object.assign({}, userEnv)
    @runSpec spec, copyEnv() for spec in suite.specs
    @runSuite sub, copyEnv() for sub in suite.subSuites

  runSpec: (spec, userEnv) ->
    if spec.pending
      spec.skip()
      try
        spec.suite.env.onSpecPending(spec)
      finally
        return

    spec.ran = true
    try
      @runHooks(spec, 'beforeEach', userEnv)
      spec.itFn.call(userEnv)
      @runHooks(spec, 'afterEach', userEnv)

      spec.pass()
      @executeSafe -> spec.suite.env.onSpecPass(spec)
    catch ex
      @anyFailed = true
      spec.fail(ex)
      @executeSafe -> spec.suite.env.onSpecFail(spec)

  runHooks: (spec, hookType, userEnv) ->
    hooks = []
    suite = spec.suite
    while suite?
      for hook in suite.hooks[hookType]
        hooks.unshift(hook)
      suite = suite.parentSuite

    for hook in hooks
      hook.call(userEnv)

  executeSafe: (fn) ->
    try
      fn()
    finally
      # nothing
