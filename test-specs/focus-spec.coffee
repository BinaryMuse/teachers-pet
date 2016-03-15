assert = require 'assert'

fail = -> throw new Error("shouldn't be here")

describe 'Focus tests', ->
  it 'only runs focused tests at the exclusion of others', -> fail()
  fit 'skips focused tests lower than the max focus level', -> fail()
  ffdescribe 'nesting', ->
    it 'works properly', ->
    fit 'even with nested fit', ->
  describe 'with a non-focused describe', ->
    it 'runs none of the specs inside', -> fail()
    ffdescribe 'unless', ->
      it 'a nested describe has a focus level >= the max', ->
