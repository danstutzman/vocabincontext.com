define (require) ->
  $            = require('jquery')
  soundManager = require('cs!app/soundManager')
  Player       = require('cs!app/Player')

  ARROW_KEY_UP   = 38
  ARROW_KEY_DOWN = 40

  soundManager.onready ->
    $('#throbber-background').hide()
    $('#throbber-foreground').hide()

  if $('#canvas').length
    player = new Player(
      $('#canvas'), $('#play-button'), $('#cursor'), $('#input'),
      soundManager, '/media/dutty-love.mp3')

    resizeCanvas = ->
      @canvas.width = window.innerWidth - 16
      @canvas.style.width = "#{@canvas.width}px"

    mouseMove = (event) ->
      canvasMinX = $('#canvas').offset().left
      player.moveCursorTo(event.pageX - canvasMinX)

    $(document).ready ->
      resizeCanvas()
      player.redrawCanvas()
      $('#canvas').mousedown (event) ->
        mouseMove(event)
        $('#canvas').bind 'mousemove', mouseMove
      $('#canvas').mouseup (event) ->
        $('#canvas').unbind 'mousemove', mouseMove
      $('#cursor').mouseup (event) ->
        $('#canvas').unbind 'mousemove', mouseMove
  
    $(window).resize ->
      resizeCanvas()
      player.redrawCanvas()

  lines = $.getJSON '/media/dutty-love.json', (lines) ->
    word_to_count = {}
    for line in lines
      for word in line['lyric'].split(' ')
        word_to_count[word.toLowerCase()] ||= 0
        word_to_count[word.toLowerCase()] += 1

    sorted_words = Object.keys(word_to_count)
    sorted_words.sort (value1, value2) ->
      return -1 if value1 < value2
      return +1 if value1 > value2
      return 0

    #sort by frequency:
    #sorted_words.sort (value1, value2) ->
    #  return -1 if word_to_count[value1] < word_to_count[value2]
    #  return +1 if word_to_count[value1] > word_to_count[value2]
    #  return 0

    for word in sorted_words
      count = word_to_count[word]

      $('#words').append('<li><a class="js-word-link" data-word="' + word + '" href="#">' + word + '(' + count + ')' + '</a></li>')

    $('.js-word-link').click (event) =>
      word = event.target.getAttribute('data-word')

      $('#lyrics').empty()
      for line in lines
        if line['lyric'].indexOf(word) != -1
          $('#lyrics').append('<li><a id="' + line['id'] + '" class="js-sound-link" href="/' + line['filename'] + '">' + line['lyric'] + '</a></li>')
          $('.js-sound-link').click (event) =>
            id = event.target.id
            href = event.target.href
            soundManager.play(id, href)
            false
      false

  highlightedRow = 1
  moveHighlightRow = (delta) ->
    highlightedRow += delta
    if highlightedRow < 1
      highlightedRow = 1
    if highlightedRow > $('#js-lyrics-table tr').length
      highlightedRow = $('#js-lyrics-table tr').length
 
    $('#js-lyrics-table tr').css 'backgroundColor', 'white'
    $("#js-lyrics-table tr:nth-child(#{highlightedRow})").css 'backgroundColor', 'blue'

  $(document).keydown (event) =>
    switch event.which
      when ARROW_KEY_UP
        event.preventDefault()
        false
      when ARROW_KEY_DOWN
        event.preventDefault()
        false
      else
        true
  $(document).keyup (event) =>
    switch event.which
      when ARROW_KEY_UP
        moveHighlightRow -1
      when ARROW_KEY_DOWN
        moveHighlightRow 1
