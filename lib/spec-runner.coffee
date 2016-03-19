createTimeoutPromise = (ms) =>
  error = new Error("Waited #{ms}ms for something to happen")
  new Promise (resolve, reject) =>
    rej = ->
      reject(error)
    setTimeout rej, ms

module.exports =
class SpecRunner
  # SpecRunner takes a SpecEnvironment and runs the associated root SpecSuite
  # when `run` is called. SpecRunner is responsible for running each spec,
  # catching errors, and sending them to the reporter.
  constructor: (@env) ->
    @anyFailed = false
    @options = {}

  # Runs the root SpecSuite associated with the runner's SpecEnvironment.
  # Returns a promise resolving to `1` (if specs failed) or `0` (if specs passed).
  run: (@options) ->
    {rootSuite, userEnv} = @env
    @env.running = true
    @installUncaughtHandler()
    @runSuite rootSuite, userEnv
      .catch (err) ->
        console.error "Spec run failed (promise was rejected in SpecRunner):"
        console.error err.stack ? err
        @anyFailed = true
      .then => @uninstallUncaughtHandler()
      .then => @env.running = false
      .then => if @anyFailed then 1 else 0

  installUncaughtHandler: =>
    process.on 'uncaughtException', @handleUncaughtException

  uninstallUncaughtHandler: =>
    process.removeListener 'uncaughtException', @handleUncaughtException

  handleUncaughtException: (err) ->
    console.error "Uncaught exception while running a test suite:"
    console.error err.stack

  # Runs a single SpecSuite, including all sub-suites and contained specs.
  # Returns a promise that always resolves to a null value when the suite is
  # done running.
  runSuite: (suite, userEnv) ->
    copyEnv = -> Object.assign({}, userEnv)

    onSuiteStart = =>
      @options.onSuiteStart?(suite)
      null
    onSuiteEnd = =>
      @options.onSuiteEnd?(suite)
      null

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

  # `runSpec` runs a single Spec, and returns a promise when the spec
  # completes. The promise contains no success or failure information;
  # spec failure information is stored directly on the Spec object.
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

  # Executes `fn` using `userEnv` as the `this` context.
  # If `fn` has a zero length, `executeAsyncSpecFn` returns a promise resolving
  # to the return value of `fn`.
  #
  # If `fn` has a positive length, a callback is passed as the first argument
  # to `fn`. If the callback is not called within `timeout` ms, `executeAsyncSpecFn`
  # returns a promise rejected with a timeout error. Furthermore, if the callback
  # is called with a first parameter, the promise is rejected with that value.
  # Finally, if no other errors occur, the promise is resolved with the return
  # value of `fn` (useful for accidental unhandled rejected promises).
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
