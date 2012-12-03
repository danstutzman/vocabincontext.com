define (require) ->
  $            = require('jquery')
  ProgressBar  = require('cs!app/ProgressBar')

  class YouTubePlayer
    constructor: (sound) ->
      @_sound = sound
      @_progress = new ProgressBar(@_sound)

    init: ($player) ->
      @$player = $player
      @$player.append "
        <button class='play-button clickable'>Play</button>
        <div class='progress-bar'></div>
        "
      @$playButton  = @$player.children('.play-button')
      @$progressBar = @$player.children('.progress-bar')

      @$playButton.click =>
        @_sound.toggleIsPlaying()
        false

      @_progress.init @$progressBar, @$playButton
