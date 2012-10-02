define (require) ->
  SoundGrid = require('cs!app/SoundGrid')

  class Player
    constructor: ($canvas, $playButton, $cursor, sm, mp3Url) ->
      @canvas = $canvas[0]
      @$playButton = $playButton
      @cursor = $cursor[0]
      @context = @canvas.getContext('2d')
      @theSound = undefined
      @isPaused = true
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
      @soundGrid = null # wait until we know the sound's duration

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
  
    drawStripe: (x, stripe) ->
      if stripe
        for y in [0...@column.height]
          value = 255 - (stripe[y] * 255)
          @column.data[y*4 + 0] = value
          @column.data[y*4 + 1] = value
          @column.data[y*4 + 2] = value
          @column.data[y*4 + 3] = 255
      else
        # draw gray background if no data
        for y in [0...@column.height]
          @column.data[y*4 + 0] = 192
          @column.data[y*4 + 1] = 192
          @column.data[y*4 + 2] = 192
          @column.data[y*4 + 3] = 255
      @context.putImageData(@column, x, 0)
  
    redrawCanvas: ->
      if @soundGrid
        stripes = @soundGrid.resize(@canvas.width, @canvas.height)
      else
        stripes = {}
        for x in [0...@canvas.width]
          stripes[x] = null

      for own x, stripe of stripes
        @drawStripe(x, stripe)

      @updateCursorX()
  
    whilePlaying: ->
      if @theSound.duration && !@soundGrid
        @soundGrid =
          new SoundGrid(@canvas.width, @canvas.height, @theSound.duration)
      try
        peakData = @theSound.peakData
        if peakData && not @justSetPosition && @soundGrid
          energy = (peakData.left + peakData.right) / 2
          stripes = @soundGrid.addData(@theSound.position, energy)
          for own x, stripe of stripes
            @drawStripe(x, stripe)
        @updateCursorX()
        @justSetPosition = false
      catch error
        console.log "Error in whilePlaying: #{error}"
  
    moveCursorTo: (x) ->
      millis = x * @theSound.duration / @canvas.width
      @justSetPosition = true
      @theSound.setPosition millis
      @updateCursorX()