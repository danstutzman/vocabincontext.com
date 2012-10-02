define (require) ->
  TimeSeries = require('cs!app/TimeSeries').TimeSeries

  class Player
    constructor: ($canvas, $playButton, sm, mp3Url) ->
      @canvas = $canvas[0]
      @$playButton = $playButton
      @context = @canvas.getContext('2d')
      @theSound = undefined
      @isPaused = true
      @timeSeries = new TimeSeries()
      @justSetPosition = false
      @lastCursorX = 0
      @sm = sm
      @sm.onready =>
        @theSound = @sm.createSound
          id: 'theSound'
          url: mp3Url
          useEQData: true
          usePeakData: true
          whileplaying: => @whilePlaying()
          onfinish: => @onFinish()
        @setupPlayButton()

    updatePlayButtonLabel: ->
      if @isPaused
        @$playButton.text 'Play'
      else
        @$playButton.text 'Pause'
    
    setupPlayButton: ->
      @$playButton.attr 'disabled', false
      @$playButton.bind 'click', =>
        if @isPaused
          @theSound.play()
          @isPaused = false
          @updatePlayButtonLabel()
        else
          @theSound.pause()
          @isPaused = true
          @updatePlayButtonLabel()
    
    redrawCursor: ->
      if @theSound
        cursorX =
          Math.floor(@canvas.width * @theSound.position / @theSound.duration)
        @drawFakeWaveformStripe(@lastCursorX) # erase old cursor
        @context.fillStyle = 'rgb(255,0,0)'
        @context.fillRect cursorX, 0, 1, @canvas.height
        @lastCursorX = cursorX
  
    onFinish: ->
      try
        @isPaused = true
        @updatePlayButtonLabel()
      catch error
        console.log "Error in onFinish: #{error}"
  
    drawFakeWaveformStripe: (x) ->
      position = x / @canvas.width
      height = @timeSeries.getClosestValue(position) * 100 + 0.25
      @context.clearRect x, 0, 1, @canvas.height
      @context.fillStyle = 'rgb(0,0,0)'
      # add 0.5 to avoid the line straddling the middle
      @context.fillRect x, @canvas.height / 2 + 0.5 - height, 1, height * 2
  
    redrawCanvas: ->
      for x in [0..@canvas.width]
        @drawFakeWaveformStripe(x)
      @redrawCursor()
  
    whilePlaying: ->
      try
        peakData = @theSound.peakData
        if peakData && not justSetPosition && @theSound.duration
          # draw fake waveform
          position = @theSound.position / @theSound.duration
          cursorX = Math.floor(@canvas.width * position)
          previousX = Math.floor(@timeSeries.getClosestKey(position) *
            @canvas.width)
          @timeSeries.add position, (peakData.left + peakData.right) / 2
          for x in [previousX..cursorX]
            @drawFakeWaveformStripe(x)
        @redrawCursor()
        justSetPosition = false
      catch error
        console.log "Error in whilePlaying: #{error}"
  
    moveCursorTo: (x) ->
      millis = x * @theSound.duration / @canvas.width
      @justSetPosition = true
      @theSound.setPosition millis
      @redrawCursor()
