define (require) ->
  $ = require('jquery')
  SoundGrid = require('cs!app/SoundGrid')

  class Mp3Player
    constructor: ($player, sm, mp3Url) ->
      $player.append "
        <div class='cursor'></div>
        <canvas class='canvas' width='50' height='100'>
          HTML5 Canvas element not supported.
        </canvas>
        <button class='play-button clickable' disabled='disabled'>
          Play</button>"
      @$canvas     = $player.children('.canvas')
      @$playButton = $player.children('.play-button')
      @$cursor     = $player.children('.cursor')

      @context = @$canvas[0].getContext('2d')

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
      @column = @context.createImageData(1, @$canvas.height())
      @soundGrid = null # wait until we know the sound's duration

      resizeCanvas = =>
        @$canvas.width window.innerWidth - 16
        @$canvas.attr 'width', @$canvas.width()
  
      mouseMove = (event) =>
        canvasMinX = @$canvas.offset().left
        @moveCursorTo(event.pageX - canvasMinX)
  
      $(document).ready =>
        resizeCanvas()
        @redrawCanvas()
        @$canvas.mousedown (event) ->
          mouseMove(event)
          @$canvas.bind 'mousemove', mouseMove
        @$canvas.mouseup (event) ->
          @$canvas.unbind 'mousemove', mouseMove
        @$cursor.mouseup (event) ->
          @$canvas.unbind 'mousemove', mouseMove
  
      $(window).resize =>
        resizeCanvas()
        @redrawCanvas()

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
      #console.log 'updateCursorX', @theSound.duration
      if @theSound && @theSound.duration
        cursorX =
          Math.floor(@$canvas.width() * @theSound.position / @theSound.duration)
        #console.log 'cursor is now at', "#{cursorX + 1}px"
        @$cursor.css 'left', "#{cursorX + 1}px" # add 1 for border
  
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
        stripes = @soundGrid.resize(@$canvas.width(), @$canvas.height())
      else
        stripes = {}
        for x in [0...@$canvas.width()]
          stripes[x] = null

      for own x, stripe of stripes
        @drawStripe(x, stripe)

      @updateCursorX()
  
    whilePlaying: ->
      # console.log 'whilePlaying', @theSound.position, @theSound.duration, \
      #   @theSound.peakData.left, @theSound.peakData.right
      if @theSound.duration && !@soundGrid
        @soundGrid =
          new SoundGrid(@$canvas.width(), @$canvas.height(), @theSound.duration)
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
      millis = x * @theSound.duration / @$canvas.width()
      @justSetPosition = true
      @theSound.setPosition millis
      @updateCursorX()

    getPosition: ->
      @theSound.position
