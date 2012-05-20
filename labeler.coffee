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
    context = $('#canvas')[0]
    context = canvas.getContext('2d')
    millisecondsToPixels = 0.05
    actualX = Math.floor(@position * millisecondsToPixels)
    context.fillStyle = 'rgb(0,0,0)'

    # draw fake waveform
    if @peakData
      height = (@peakData.left + @peakData.right) / 2 * 18
      context.clearRect lastActualX, 260,
        actualX - lastActualX, canvas.height - 260
      context.fillStyle = 'rgb(0,0,0)'
      context.fillRect lastActualX, 280 - height,
        actualX - lastActualX, height * 2
    lastActualX = actualX

    relative = @position / @duration
    $("#slider").slider 'option', 'value', relative * 100

  catch error
    console.log "Error in whilePlaying: #{error}"

sm = window.soundManager
sm.url = 'soundmanagerv297a-20120513/swf'
sm.debugMode = false
sm.useFlashBlock = false
sm.flashVersion = 9
sm.flash9Options.useEQData = true
sm.flash9Options.usePeakData = true
sm.useHighPerformance = true
sm.useFastPolling = true
sm.onready ->
  theSound = soundManager.createSound
    id: 'theSound'
    url: '/Eb-chord.mp3'
    useEQData: true
    usePeakData: true
    whileplaying: whilePlaying
  setupPlayButton()

$(document).ready ->
  updateSliderFromSound()
