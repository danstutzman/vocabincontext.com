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
  
  lastActualX = 0
  whilePlaying = ->
    try
      canvas = $('#canvas')[0]
      context = canvas.getContext('2d')
      actualX = Math.floor(canvas.width * @position / @duration)
      context.fillStyle = 'rgb(0,0,0)'
      context.strokeStyle = "black"
      context.lineWidth = '1'

  
      # draw fake waveform
      if @peakData
        # add 0.25 so there's a minimum 1-pix line
        height = ((@peakData.left + @peakData.right) / 2 * 50) + 0.25
        context.clearRect lastActualX, 0,
          actualX - lastActualX, canvas.height
        context.fillStyle = 'rgb(0,0,0)'
        # add 0.5 to avoid the line straddling the middle
        context.fillRect lastActualX, canvas.height / 2 + 0.5 - height,
          actualX - lastActualX, height * 2
      lastActualX = actualX
  
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

  resizeCanvas = ->
    canvas = $('#canvas')[0]
    canvas.width = window.innerWidth - 20
  
  $(document).ready ->
    updateSliderFromSound()
    resizeCanvas()

  $(window).resize ->
    resizeCanvas()
