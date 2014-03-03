ImgLoaded = require '../../../../lib/api/assert/imgLoaded'
assert = require 'assertive'

describe 'imgLoaded', ->
  driver =
    evaluate: -> true
  imgLoaded = ImgLoaded(driver).imgLoaded

  it 'fails if selector is undefined', ->
    assert.throws ->
      imgLoaded(undefined)

  it 'fails if selector is not a String', ->
    assert.throws ->
      imgLoaded(->)

  it 'succeeds if all conditions are met', ->
    imgLoaded('.thumb')

