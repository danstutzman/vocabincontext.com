# don't init soundManager until beginDelayedInit() is called
window.SM2_DEFER = true

require [
#  'order!http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js',
#  'order!http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js',
  'order!jquery-1.7.2.min.js',
  'order!jquery-ui-1.8.20.custom.min.js',
  'soundmanagerv297a-20120513/script/soundmanager2.js',
  'app/TimeSeries'], (jquery, jqueryUI, soundManager, timeSeries) ->

  theSound = undefined
  
  updateSliderFromSound = ->
    $('#slider').slider
      slide: (event, ui) ->
        millis = ui.value / 100.0 * theSound.duration
        theSound.setPosition millis
  
  setupPlayButton = ->
    play = $('#play-button')
    play.attr 'disabled', false
    play.click ->
      theSound.play()
  
  canvas = $('#canvas')[0]
  context = canvas.getContext('2d')
  timeSeries = new timeSeries.TimeSeries
  whilePlaying = ->
    try
      # draw fake waveform
      if @peakData
        actualX = Math.floor(canvas.width * @position / @duration)
        position = @position / @duration
        previousX = Math.floor(timeSeries.getClosestKey(position) *
          canvas.width)
        timeSeries.add position, (@peakData.left + @peakData.right) / 2
        for x in [previousX..actualX]
          drawFakeWaveformStripe(x)
  
      relative = @position / @duration
      $("#slider").slider 'option', 'value', relative * 100
  
    catch error
      console.log "Error in whilePlaying: #{error}"
  
  sm = new SoundManager()
  sm.url = 'soundmanagerv297a-20120513/swf'
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
      url: '/Eb-chord.mp3'
      useEQData: true
      usePeakData: true
      whileplaying: whilePlaying
    setupPlayButton()
  window.soundManager = sm # Flash expects window.soundManager
  sm.beginDelayedInit()

  drawFakeWaveformStripe = (x) ->
    position = x / canvas.width
    height = timeSeries.getClosestValue(position) * 100 + 0.25
    context.clearRect x, 0, 1, canvas.height / 2
    context.fillStyle = 'rgb(0,0,0)'
    # add 0.5 to avoid the line straddling the middle
    context.fillRect x, canvas.height / 2 + 0.5 - height, 1, height * 2

  redrawCanvas = ->
    for x in [0..canvas.width]
      drawFakeWaveformStripe(x)

  resizeCanvas = ->
    canvas.width = window.innerWidth - 20
  
  $(document).ready ->
    updateSliderFromSound()
    resizeCanvas()
    redrawCanvas()

  $(window).resize ->
    resizeCanvas()
    redrawCanvas()
