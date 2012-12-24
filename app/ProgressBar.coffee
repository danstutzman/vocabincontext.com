define (require) ->
  $ = require('jquery')
  Utility = require('cs!app/Utility')

  class ProgressBar
    constructor: (player) ->
      @_player = player

    init: ($progress_bar, $play_button) ->
      @$progress_bar = $progress_bar
      @$progress_bar.append "
        <div class='loaded-bar'></div>
        <div class='bar'></div>
        <div class='total-time'></div>
        <div class='bar-caption'></div>"
      @$loaded_bar  = @$progress_bar.children('.loaded-bar')
      @$bar         = @$progress_bar.children('.bar')
      @$total_time  = @$progress_bar.children('.total-time')
      @$bar_caption = @$progress_bar.children('.bar-caption')

      @_player.addListener 'stateChange', (event) =>
        console.log 'stateChange', event.state
        @$total_time.text Utility.formatTimeMS(@_player.getDuration())
        $play_button.text @_player.getCurrentTogglePlayingVerb()

      inProgressDrag = false
      @_player.addListener 'updateProgress', =>
        unless inProgressDrag || @_player.getPosition() == null
          @_updateProgressBar @_player.getPosition(), @_player.getDuration(), \
            @_player.getVideoLoadedFraction()

      doSeek = (inDrag) =>
        (event) =>
          inProgressDrag = inDrag
          x = event.pageX - @$progress_bar[0].offsetLeft
          position = x * @_player.getDuration() / @$progress_bar.width()
          percentLoaded = @_player.getVideoLoadedFraction()
          @_updateProgressBar position, @_player.getDuration(), percentLoaded
          @_player.seekTo position, !inDrag
      draggingSeek = doSeek(true)
      doneDraggingSeek = doSeek(false)
      @$progress_bar.mousedown (event) =>
        draggingSeek(event)
        @$progress_bar.mousemove draggingSeek
        doneDragging = (event) =>
          @$progress_bar.unbind 'mousemove', draggingSeek
          $('body').unbind 'mouseup', doneDragging
          doneDraggingSeek(event)
        $('body').mouseup doneDragging

    _updateProgressBar: (soFar, toGo, percentLoaded) ->
      outerLength = @$progress_bar.width()
      barLength = outerLength * soFar / toGo

      if barLength >= 40
        @$bar.text Utility.formatTimeMS(soFar) + "\u00a0\u00a0"
        @$bar_caption.text ''
      else
        @$bar.text ''
        @$bar_caption.text "\u00a0\u00a0" + Utility.formatTimeMS(soFar)

      if outerLength - barLength < 40
        @$total_time.text ''
      else
        @$total_time.text Utility.formatTimeMS(toGo)

      @$bar.width Math.round(barLength)
      @$bar_caption.css 'margin-left', Math.round(barLength)

      @$loaded_bar.width outerLength * percentLoaded
