define (require) ->
  $            = require('jquery')
  soundManager = require('cs!app/soundManager')
  Player       = require('cs!app/Player')

  ARROW_KEY_UP    = 38
  ARROW_KEY_DOWN  = 40
  ARROW_KEY_LEFT  = 37
  ARROW_KEY_RIGHT = 39
  ARROW_KEYS = [ARROW_KEY_UP, ARROW_KEY_DOWN, ARROW_KEY_LEFT, ARROW_KEY_RIGHT]
  ENTER_KEY = 13

  getParams = ->
    result = {}
    re = /([^&=]+)=([^&]*)/g
    d = decodeURIComponent
    s = location.search
    s = if s.match /^\?/ then s.substring(1) else s
    while match = re.exec(s)
      result[d(match[1])] = d match[2]
    result

  soundManager.onready ->
    $('#throbber-background').hide()
    $('#throbber-foreground').hide()

  song = getParams()['song']
  if !song
    alert 'Please specify a song parameter'

  # add player in canvas
  if $('#player').length
    mp3Link = "/media/whole_songs/#{song}.mp3"
    player = new Player($('#player'), $, soundManager, mp3Link)

  lines = $.getJSON "/media/lyrics_json/#{song}.json", (lines) ->
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

  highlightY = 1
  highlightX = 2

  drawHighlight = (isVisible, colNum, rowNum) ->
    if isVisible
      $("#js-lyrics-table tr:nth-child(#{highlightY})").addClass 'selectedRow'
      $("#js-lyrics-table tr:nth-child(#{highlightY}) td:nth-child(#{highlightX})").addClass 'selectedCell'
    else
      $("#js-lyrics-table tr:nth-child(#{highlightY})").removeClass 'selectedRow'
      $("#js-lyrics-table tr:nth-child(#{highlightY}) td:nth-child(#{highlightX})").removeClass 'selectedCell'

  moveHighlight = (xDelta, yDelta) ->
    drawHighlight false, highlightX, highlightY

    highlightX += xDelta
    if highlightX < 1
      highlightX = 1
    if highlightX > 3
      highlightX = 3

    highlightY += yDelta
    if highlightY < 1
      highlightY = 1
    if highlightY > $('#js-lyrics-table tr').length
      highlightY = $('#js-lyrics-table tr').length
 
    drawHighlight true, highlightX, highlightY

  # prevent default behavior when arrow keys are pressed
  $(document).keydown (event) =>
    if ARROW_KEYS.indexOf(event.which) != -1
      event.preventDefault()
      false
    else
      true

  $(document).keyup (event) =>
    switch event.which
      when ARROW_KEY_UP
        moveHighlight 0, -1
      when ARROW_KEY_DOWN
        moveHighlight 0, 1
      when ARROW_KEY_LEFT
        moveHighlight -1, 0
      when ARROW_KEY_RIGHT
        moveHighlight 1, 0
      when ENTER_KEY
        $("#js-lyrics-table tr:nth-child(#{highlightY + 1}) td:nth-child(1)").html(player.getPosition())
        moveHighlight 0, 1

  if $('#js-lyrics-table').length
    $.ajax
      url: "/media/lyrics_txt/#{song}.txt"
      success: (data, textStatus, jqXHR) ->
        for line in data.split("\n")
          if match = line.match(/^([0-9]+)\s+(.*)$/)
            start_time = match[1]
            lyric = match[2]
          else
            start_time = ''
            lyric = line
          newRow = "<tr><td>#{start_time}</td><td>#{lyric}</td><td></td></tr>"
          $('#js-lyrics-table > tbody').append newRow
