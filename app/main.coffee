# don't init soundManager until beginDelayedInit() is called
window.SM2_DEFER = true

require [
  '/lib/jquery-1.7.2.min.js',
  '/lib/soundmanagerv297a-20120513/script/soundmanager2.js',
  '/app/TimeSeries.js'], (jquery, soundManager, timeSeries) ->

  theSound = undefined
  isPaused = true

  updatePlayButtonLabel = ->
    play = $('#play-button')
    if isPaused
      play.text 'Play'
    else
      play.text 'Pause'
  
  setupPlayButton = ->
    play = $('#play-button')
    play.attr 'disabled', false
    play.bind 'click', ->
      if isPaused
        theSound.play()
        isPaused = false
        updatePlayButtonLabel()
      else
        theSound.pause()
        isPaused = true
        updatePlayButtonLabel()
  
  canvas = $('#canvas')[0]
  context = canvas.getContext('2d')
  timeSeries = new timeSeries.TimeSeries
  justSetPosition = false
  whilePlaying = ->
    try
      # draw fake waveform
      if @peakData && not justSetPosition
        cursorX = Math.floor(canvas.width * @position / @duration)
        position = @position / @duration
        previousX = Math.floor(timeSeries.getClosestKey(position) *
          canvas.width)
        timeSeries.add position, (@peakData.left + @peakData.right) / 2
        for x in [previousX..cursorX]
          drawFakeWaveformStripe(x)
      redrawCursor()
      justSetPosition = false
    catch error
      console.log "Error in whilePlaying: #{error}"

  lastCursorX = 0
  redrawCursor = ->
    if theSound
      cursorX = Math.floor(canvas.width * theSound.position / theSound.duration)
      drawFakeWaveformStripe(lastCursorX) # erase old cursor
      context.fillStyle = 'rgb(255,0,0)'
      context.fillRect cursorX, 0, 1, canvas.height
      lastCursorX = cursorX

  onFinish = ->
    try
      isPaused = true
      updatePlayButtonLabel()
    catch error
      console.log "Error in onFinish: #{error}"

  hideThrobber = ->
    $('#throbber-background').hide()
    $('#throbber-foreground').hide()
  
  sm = new SoundManager()
  sm.url = '/lib/soundmanagerv297a-20120513/swf'
  sm.debugMode = false
  sm.useFlashBlock = false
  sm.flashVersion = 9
  sm.flash9Options.useEQData = true
  sm.flash9Options.usePeakData = true
  #sm.useHighPerformance = true
  #sm.useFastPolling = true
  sm.onready ->
    theSound = sm.createSound
      id: 'theSound'
      url: '/media/03.mp3'
      useEQData: true
      usePeakData: true
      whileplaying: whilePlaying
      onfinish: onFinish
    setupPlayButton()
    hideThrobber()
  window.soundManager = sm # Flash expects window.soundManager
  sm.beginDelayedInit()

  drawFakeWaveformStripe = (x) ->
    position = x / canvas.width
    height = timeSeries.getClosestValue(position) * 100 + 0.25
    context.clearRect x, 0, 1, canvas.height
    context.fillStyle = 'rgb(0,0,0)'
    # add 0.5 to avoid the line straddling the middle
    context.fillRect x, canvas.height / 2 + 0.5 - height, 1, height * 2

  redrawCanvas = ->
    for x in [0..canvas.width]
      drawFakeWaveformStripe(x)
    redrawCursor()

  resizeCanvas = ->
    canvas.width = window.innerWidth - 16
    canvas.style.width = "#{canvas.width}px"

  mouseMove = (event) ->
    millis = event.pageX * theSound.duration / canvas.width
    justSetPosition = true
    theSound.setPosition millis
    redrawCursor()
  
  $(document).ready ->
    resizeCanvas()
    redrawCanvas()
    $('#canvas').mousedown (event) ->
      mouseMove(event)
      $('#canvas').bind 'mousemove', mouseMove
    $('#canvas').mouseup (event) ->
      $('#canvas').unbind 'mousemove', mouseMove

  $(window).resize ->
    resizeCanvas()
    redrawCanvas()
