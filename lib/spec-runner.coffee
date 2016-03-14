createTimeoutPromise = (ms) =>
  error = new Error("Waited #{ms}ms for something to happen")
  new Promise (resolve, reject) =>
    rej = ->
      reject(error)
    setTimeout rej, ms

module.exports =
class SpecRunner
  constructor: (@env) ->
    @anyFailed = false
    @options = {}

  run: (@options) ->
    {rootSuite, userEnv} = @env
    @installUncaughtHandler()
    @runSuite rootSuite, userEnv
      .then @uninstallUncaughtHandler
      .then => if @anyFailed then 1 else 0
      .catch (err) ->
        console.error "Spec run failed (promise was rejected):"
        console.error err.stack ? err

  installUncaughtHandler: =>
    process.on 'uncaughtException', @handleUncaughtException

  uninstallUncaughtHandler: =>
    process.removeListener 'uncaughtException', @handleUncaughtException

  handleUncaughtException: (err) ->
    console.error "Uncaught exception while running a test suite:"
    console.error err.stack

  runSuite: (suite, userEnv) ->
    copyEnv = -> Object.assign({}, userEnv)

    onSuiteStart = =>
      @options.onSuiteStart?(suite)
    onSuiteEnd = =>
      @options.onSuiteEnd?(suite)

    p = Promise.resolve()
    p = p.then(onSuiteStart)
    for spec in suite.specs
      do (spec) =>
        next = () => @runSpec(spec, copyEnv())
        p = p.then(next, next)
    for sub in suite.subSuites
      do (sub) =>
        next = () => @runSuite(sub, copyEnv())
        p = p.then(next, next)
    p = p.then(onSuiteEnd, onSuiteEnd)

    p

  runSpec: (spec, userEnv) ->
    @options.onSpecStart?(spec)

    if spec.isPending()
      spec.skip()
      @options.onSpecEnd?(spec, "skip")
      return null

    specPassed = =>
      spec.pass()
      @options.onSpecEnd?(spec, "pass")
      null

    specFailed = (ex) =>
      @anyFailed = true
      spec.fail(ex)
      @options.onSpecEnd?(spec, "fail")
      null

    timeout = spec.userOptions.timeout ? @env.options.asyncTimeout
    specResultPromise = Promise.resolve()
      .then => @runHooks(spec, 'beforeEach', userEnv, timeout)
      .then => @executeAsyncSpecFn(spec.itFn, userEnv, timeout)
      .then => @runHooks(spec, 'afterEach', userEnv, timeout)

    specResultPromise
      .then(specPassed, specFailed)

  runHooks: (spec, hookType, userEnv, timeout) ->
    suite = spec.suite
    parents = [suite]
    while suite.parentSuite?
      parents.unshift suite.parentSuite
      suite = suite.parentSuite
    hooks = (parent.hooks[hookType] for parent in parents)
    hooks = [].concat.apply([], hooks)

    p = Promise.resolve()
    for hook in hooks
      do (hook) =>
        p = p.then => @executeAsyncSpecFn(hook, userEnv, timeout)
    p

  executeAsyncSpecFn: (fn, userEnv, timeout) ->
    promise = new Promise (resolve, reject) ->
      try
        if fn.length is 0
          resolve(fn.call(userEnv))
        else
          val = fn.call userEnv, (err) =>
            if err?
              reject(err)
            else
              resolve(val)
      catch ex
        reject(ex)
    if timeout?
      promise = Promise.race([promise, createTimeoutPromise(timeout)])
    promise

  executeSafe: (fn) ->
    try fn()
