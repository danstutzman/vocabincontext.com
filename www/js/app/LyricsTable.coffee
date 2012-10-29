define (require) ->
  $ = require('jquery')

  ARROW_KEY_UP    = 38
  ARROW_KEY_DOWN  = 40
  ARROW_KEY_LEFT  = 37
  ARROW_KEY_RIGHT = 39
  ARROW_KEYS = [ARROW_KEY_UP, ARROW_KEY_DOWN, ARROW_KEY_LEFT, ARROW_KEY_RIGHT]
  ENTER_KEY = 13

  objectToXY = (object) ->
    if object.offsetParent
      x = 0
      y = 0
      parent = object
      while parent
        x += parent.offsetLeft
        y += parent.offsetTop
        parent = parent.offsetParent
      { x:x, y:y, w:object.offsetWidth, h:object.offsetHeight }

  init = (song, player) ->
    highlightY = 1
    highlightX = 2
  
    drawHighlight = (isVisible) ->
      rowSelector = "#js-lyrics-table tr:nth-child(#{highlightY})"
      colSelector = "#{rowSelector} td:nth-child(#{highlightX})"
      if isVisible
        $(rowSelector).addClass 'selectedRow'
        $(colSelector).addClass 'selectedCell'
      else
        $(rowSelector).removeClass 'selectedRow'
        $(colSelector).removeClass 'selectedCell'

    scrollToShowHighlight = ->
      rowSelector = "#js-lyrics-table tr:nth-child(#{highlightY})"
      {x, y, w, h} = objectToXY($(rowSelector)[0])

      scrollTop = window.pageYOffset
      if y < scrollTop
        $('body')[0].scrollTop = y

      scrollbarSize = $('.scrollbar-measure')[0].offsetWidth - \
        $('.scrollbar-measure')[0].clientWidth
      windowSize = window.innerHeight - scrollbarSize
      scrollBottom = window.pageYOffset + windowSize
      if (y + h) > scrollBottom
        $('body')[0].scrollTop = (y + h) - windowSize
  
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
      scrollToShowHighlight()
  
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
  
  { init: init }
