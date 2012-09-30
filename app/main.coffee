# don't init soundManager until beginDelayedInit() is called
window.SM2_DEFER = true

require [
    '/lib/jquery-1.7.2.min.js',
    '/lib/soundmanagerv297a-20120513/script/soundmanager2.js',
    '/app/Player.js',
    ], (jquery, soundManager, Player) ->

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
    hideThrobber()
  window.soundManager = sm # Flash expects window.soundManager
  sm.beginDelayedInit()

  hideThrobber = ->
    $('#throbber-background').hide()
    $('#throbber-foreground').hide()

  player = new Player($('#canvas'), $('#play-button'), sm, '/media/03.mp3')

  resizeCanvas = ->
    canvas.width = window.innerWidth - 16
    canvas.style.width = "#{canvas.width}px"

  mouseMove = (event) ->
    player.moveCursorTo(event.pageX)
  
  $(document).ready ->
    resizeCanvas()
    player.redrawCanvas()
    $('#canvas').mousedown (event) ->
      mouseMove(event)
      $('#canvas').bind 'mousemove', mouseMove
    $('#canvas').mouseup (event) ->
      $('#canvas').unbind 'mousemove', mouseMove

  $(window).resize ->
    resizeCanvas()
    player.redrawCanvas()
