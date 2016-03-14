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

    p = Promise.resolve()
    for spec in suite.specs
      do (spec) =>
        next = () => @runSpec(spec, copyEnv())
        p = p.then(next, next)
    for suite in suite.subSuites
      do (suite) =>
        next = () => @runSuite(suite, copyEnv())
        p = p.then(next, next)

    p

  runSpec: (spec, userEnv) ->
    if spec.isPending()
      spec.skip()
      @options.onSpecPending?(spec)
      return null

    specPassed = =>
      spec.pass()
      @options.onSpecPass?(spec)
      null

    specFailed = (ex) =>
      @anyFailed = true
      spec.fail(ex)
      @options.onSpecFail?(spec)
      null

    timeout = spec.userOptions.timeout ? @env.options.asyncTimeout
    specResultPromise = Promise.resolve()
      .then => @runHooks(spec.suite, 'beforeEach', userEnv, timeout)
      .then => @executeAsyncSpecFn(spec.itFn, userEnv, timeout)
      .then => @runHooks(spec.suite, 'afterEach', userEnv, timeout)

    specResultPromise
      .then(specPassed, specFailed)

  runHooks: (suite, hookType, userEnv, timeout) ->
    parents = [suite]
    while suite.parentSuite?
      parents.unshift suite.parentSuite
      suite = suite.parentSuite
    hooks = (parent.hooks[hookType] for parent in parents)
    hooks = [].concat.apply([], hooks)

    p = Promise.resolve()
    for hook in hooks
      do (hook) =>
        p = p.then(=> @executeAsyncSpecFn(hook, userEnv, timeout))
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
