define (require) ->
  swfobject = require('swfobject')
  EventTarget = require('cs!app/EventTarget')

  class YouTubePlayer extends EventTarget
    @IS_PLAYING = 1

    constructor: ->
      super()
      @player = null

    init: (parentId, playerId, videoId) ->
      window.onYouTubePlayerReady = =>
        console.log 'ready'
        ytplayer = document.getElementById(playerId)
        @player = ytplayer
        ytplayer.addEventListener 'onStateChange', 'onytplayerStateChange'

        updateProgress = =>
          if @player
            @fire 'updateProgress'
        window.setInterval updateProgress, 1000

      window.onytplayerStateChange = (newState) =>
        try
          @fire { name: 'stateChange', state: newState }
        catch error
          console.error error

      params = { allowScriptAccess: 'always' }
      atts = { id: playerId }
      url = "http://www.youtube.com/v/#{videoId}?enablejsapi=1&version=3"
      swfobject.embedSWF url, parentId, '425', '356', '8',
        null, null, params, atts

    getPosition: ->
      if @player && @player.getPlayerState() == @constructor.IS_PLAYING
        Math.round(@player.getCurrentTime() * 100)
      else
        null

    getDuration: ->
      @player && Math.round(@player.getDuration() * 100)

    getVideoLoadedFraction: ->
      @player && @player.getVideoLoadedFraction()

    toggleIsPlaying: ->
      if @player
        if @player.getPlayerState() == @constructor.IS_PLAYING
          @player.pauseVideo()
        else
          @player.playVideo()

    getCurrentTogglePlayingVerb: ->
      if @player && @player.getPlayerState() == @constructor.IS_PLAYING
        'Pause'
      else
        'Play'

    seekTo: (positionInCentis, allowSeekAhead) ->
      @player.seekTo positionInCentis / 100, allowSeekAhead
