define (require) ->
  class YouTubePlayer
    @IS_PLAYING = 1

    constructor: (player) ->
      @player = player
    getPosition: ->
      if @player.getPlayerState() == @constructor.IS_PLAYING
        @player.getCurrentTime() * 1000
      else
        null
