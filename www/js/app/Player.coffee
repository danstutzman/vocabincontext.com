define (require) ->
  TimeSeries = require('cs!app/TimeSeries').TimeSeries

  class Player
    constructor: ($canvas, $playButton, $cursor, sm, mp3Url) ->
      @canvas = $canvas[0]
      @$playButton = $playButton
      @cursor = $cursor[0]
      @context = @canvas.getContext('2d')
      @theSound = undefined
      @isPaused = true
      @timeSeries = new TimeSeries()
      @justSetPosition = false
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
      @column = @context.createImageData(1, @canvas.height)

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
    
    updateCursorX: ->
      if @theSound && @theSound.duration
        cursorX =
          Math.floor(@canvas.width * @theSound.position / @theSound.duration)
        @cursor.style.left = "#{cursorX + 1}px" # add 1 for border
  
    onFinish: ->
      try
        @isPaused = true
        @updatePlayButtonLabel()
      catch error
        console.log "Error in onFinish: #{error}"
  
    drawFakeWaveformStripe: (x) ->
      position = x / @canvas.width
      height = @timeSeries.getClosestValue(position) * 100 + 0.25
      y0 = Math.floor((@canvas.height / 2) - height/2)
      y1 = y0 + height

      # clear the column (make the background all white)
      for i in [0...(@column.height * 4)]
        @column.data[i] = 255

      # draw a black line from y0 to y1
      for y in [y0...y1]
        @column.data[y*4 + 0] = 0
        @column.data[y*4 + 1] = 0
        @column.data[y*4 + 2] = 0
        @column.data[y*4 + 3] = 255

      @context.putImageData(@column, x, 0)
  
    redrawCanvas: ->
      for x in [0..@canvas.width]
        @drawFakeWaveformStripe(x)
      @updateCursorX()
  
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
        @updateCursorX()
        justSetPosition = false
      catch error
        console.log "Error in whilePlaying: #{error}"
  
    moveCursorTo: (x) ->
      millis = x * @theSound.duration / @canvas.width
      @justSetPosition = true
      @theSound.setPosition millis
      @updateCursorX()
