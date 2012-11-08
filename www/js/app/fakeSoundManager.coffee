define (require) ->
  $ = require('jquery')

  class FakeSound
    constructor: (params) ->
      @params = params
    play: ->
      @duration = 287477
      @peakData = { left: 0, right: 0 }
      for position in [0...6000] by 500
        @position = position
        @params.whileplaying()
    pause: ->
      null

  class FakeSoundManager
    onready: (callback) ->
      $(callback)
    createSound: (params) ->
      new FakeSound(params)

  sm = new FakeSoundManager()
  return sm
