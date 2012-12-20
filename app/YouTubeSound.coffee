define (require) ->
  $           = require('jquery')
  swfobject   = require('swfobject')
  EventTarget = require('cs!app/EventTarget')

  class YouTubeSound extends EventTarget
    @IS_PLAYING = 1
    @PARENT_ID = 'ytapiplayer'
    @SWF_ID = 'myytplayer'

    constructor: (video_id) ->
      super()
      @_swf = null
      @_video_id = video_id
      @_playAsap = false

    init: ->
      window.onYouTubePlayerReady = =>
        console.log 'ready'
        @_swf = document.getElementById(@constructor.SWF_ID)
        @_swf.addEventListener 'onStateChange', 'onytplayerStateChange'
        @_playAsap && @_swf.playVideo()

        updateProgress = =>
          @fire 'updateProgress' if @_swf
        window.setInterval updateProgress, 1000

      window.onytplayerStateChange = (newState) =>
        try
          @fire { name: 'stateChange', state: newState }
        catch error
          console.error error
          console.error error.stack || error.stacktrace

      $ =>
        $('body').append "<div id='#{@constructor.PARENT_ID}'></div>"
        $('body').append "<style>
          ##{@constructor.SWF_ID} {
            position: absolute; left: -999px;
          }
        </style>"

        params = { allowScriptAccess: 'always' }
        atts = { id: @constructor.SWF_ID }
        url = "http://www.youtube.com/v/#{@_video_id}?enablejsapi=1&version=3"
        swfobject.embedSWF url, @constructor.PARENT_ID, '425', '356', '8',
          null, null, params, atts

    getPosition: ->
      if @_swf && @_swf.getPlayerState() == @constructor.IS_PLAYING
        Math.round(@_swf.getCurrentTime() * 100)
      else
        null

    getDuration: ->
      @_swf && Math.round(@_swf.getDuration() * 100)

    getVideoLoadedFraction: ->
      @_swf && @_swf.getVideoLoadedFraction()

    startPlayingAsap: ->
      if @_swf
        @_swf.playVideo()
      else
        @_playAsap = true

    toggleIsPlaying: ->
      if @_swf
        if @_swf.getPlayerState() == @constructor.IS_PLAYING
          @_swf.pauseVideo()
        else
          @_swf.playVideo()

    getCurrentTogglePlayingVerb: ->
      if @_swf && @_swf.getPlayerState() == @constructor.IS_PLAYING
        'Pause'
      else
        'Play'

    seekTo: (positionInCentis, allowSeekAhead) ->
      @_swf.seekTo positionInCentis / 100, allowSeekAhead
