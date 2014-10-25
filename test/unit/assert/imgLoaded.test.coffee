ImgLoadedMixin = require '../../../lib/assert/imgLoaded'
assert = require 'assertive'
{extend} = require 'lodash'

describe 'imgLoaded', ->
  context =
    driver:
      evaluate: -> true
  extend context, ImgLoadedMixin

  it 'fails if selector is undefined', ->
    assert.throws ->
      context.imgLoaded(undefined)

  it 'fails if selector is not a String', ->
    assert.throws ->
      context.imgLoaded(->)

  it 'succeeds if all conditions are met', ->
    context.imgLoaded('.thumb')

