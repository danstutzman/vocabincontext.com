@soundManager.url = 'soundmanagerv297a-20120513/swf'
@soundManager.debugMode = false
@soundManager.useFlashBlock = false
@soundManager.flashVersion = 9
@soundManager.flash9Options.useEQData = true
@soundManager.flash9Options.usePeakData = true
@soundManager.useHighPerformance = true
@soundManager.useFastPolling = true

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
      @lastActualX = @lastActualX ? 0
      context.clearRect @lastActualX, 260,
        actualX - @lastActualX, canvas.height - 260
      context.fillStyle = 'rgb(0,0,0)'
      context.fillRect @lastActualX, 280 - height,
        actualX - @lastActualX, height * 2
    @lastActualX = actualX

    relative = @position / @duration
    $("#slider").slider 'option', 'value', relative * 100

  catch error
    console.log "Error in whilePlaying: #{error}"
  
$(document).ready ->
  $('#slider').slider slide: (event, ui) ->
    millis = ui.value / 100.0 * globals.theSound.duration
    globals.theSound.setPosition millis

@soundManager.onready ->
  window.globals = theSound: soundManager.createSound(
    id: 'theSound'
    url: '/Eb-chord.mp3'
    useEQData: true
    usePeakData: true
    whileplaying: whilePlaying
  )
