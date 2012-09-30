require [
    '/lib/jquery-1.7.2.min.js',
    '/app/SoundManager.js',
    '/app/Player.js',
    ], (jquery, soundManager, Player) ->

  soundManager.onready ->
    $('#throbber-background').hide()
    $('#throbber-foreground').hide()

  player = new Player(
    $('#canvas'), $('#play-button'), soundManager, '/media/03.mp3')

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
