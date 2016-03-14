fs = require 'fs'
path = require 'path'
vm = require 'vm'

coffee = require 'coffee-script'
yargs = require 'yargs'

SpecEnvironment = require './spec-environment'
SpecRunner = require './spec-runner'

loadSpecFile = (specFile, vmContext) ->
  filePath = path.resolve(specFile)
  code = fs.readFileSync(filePath, 'utf8')
  if path.extname(specFile) is ".coffee"
    code = coffee.compile(code)
  script = new vm.Script(code, filename: specFile)
  script.runInContext vmContext

createContext = (env) ->
  newExports = {}
  newModule =
    exports: newExports

  safeContext = Object.assign {}, global,
    require: require,
    exports: newExports,
    module: newModule,

    describe: env.describe
    xdescribe: env.xdescribe
    it: env.it
    xit: env.xit
    beforeEach: env.beforeEach
    afterEach: env.afterEach
  vm.createContext safeContext

getReporterByName = (name = "default") ->
  file = path.join(__dirname, 'reporters', "#{name}-reporter")
  require file



argv = yargs.argv
specFiles = argv._
reporter = argv.reporter

if not specFiles.length
  console.error "No spec files specified"
  process.exit 1

SpecReporter = getReporterByName argv.reporter
reporter = new SpecReporter()
env = new SpecEnvironment(reporter)
runner = new SpecRunner(env)
context = createContext(env)
loadSpecFile spec, context for spec in specFiles
exitCode = runner.run
  onSpecPending: reporter.onSpecPending
  onSpecPass: reporter.onSpecPass
  onSpecFail: reporter.onSpecFail

reporter.report(env)

process.exit(exitCode)
