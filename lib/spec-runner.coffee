module.exports =
class SpecRunner
  constructor: (@env) ->
    @anyFailed = false
    @options = {}

  run: (@options) ->
    {rootSuite, userEnv} = @env
    @runSuite(rootSuite, userEnv)

    if @anyFailed then 1 else 0

  runSuite: (suite, userEnv) ->
    copyEnv = -> Object.assign({}, userEnv)
    @runSpec spec, copyEnv() for spec in suite.specs
    @runSuite sub, copyEnv() for sub in suite.subSuites

  runSpec: (spec, userEnv) ->
    if spec.isPending()
      spec.skip()
      @executeSafe -> @options.onSpecPending?(spec)
      return

    try
      @runHooks(spec.suite, 'beforeEach', userEnv)
      spec.itFn.call(userEnv)
      @runHooks(spec.suite, 'afterEach', userEnv)

      spec.pass()
      @executeSafe => @options.onSpecPass?(spec)
    catch ex
      @anyFailed = true
      spec.fail(ex)
      @executeSafe => @options.onSpecFail?(spec)

  runHooks: (suite, hookType, userEnv) ->
    if suite.parentSuite?
      @runHooks suite.parentSuite, hookType, userEnv
    hook.call(userEnv) for hook in suite.hooks[hookType]

  executeSafe: (fn) ->
    try fn()
