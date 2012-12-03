define (require) ->
  EventTarget = require('cs!app/EventTarget')
  class FakeYouTubeSound extends EventTarget
    init: ->
      @fire 'updateProgress'
    getPosition: -> (1 * 60 + 23) * 100
    getDuration: -> (2 * 60 + 34) * 100
    getCurrentTogglePlayingVerb: -> 'Play'
    getVideoLoadedFraction: -> 0.75
