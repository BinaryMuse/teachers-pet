path = require 'path'

SpecEnvironment = require './spec-environment'
SpecReporter = require './spec-reporter'
SpecRunner = require './spec-runner'

loadSpecFile = (specFile) ->
  filePath = path.resolve(process.cwd(), specFile)
  require filePath

createGlobals = (env) ->
  global.describe = env.describe
  global.xdescribe = env.xdescribe
  global.it = env.it
  global.xit = env.xit
  global.beforeEach = env.beforeEach
  global.afterEach = env.afterEach


specFiles = process.argv[2...]
if not specFiles.length
  console.error "No spec files specified"
  process.exit 1

reporter = new SpecReporter()
env = new SpecEnvironment(reporter)
runner = new SpecRunner(env)
createGlobals(env)
loadSpecFile spec for spec in specFiles
code = runner.run
  onSpecPending: reporter.onSpecPending
  onSpecPass: reporter.onSpecPass
  onSpecFail: reporter.onSpecFail

reporter.report(env)

process.exit(code)
