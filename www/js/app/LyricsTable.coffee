define (require) ->
  $ = require('jquery')

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

  class LyricsTable
    @ARROW_KEY_UP: 38
    @ARROW_KEY_DOWN: 40
    @ENTER_KEY: 13
    @S_KEY: 83
    @ARROW_KEYS: [@ARROW_KEY_UP, @ARROW_KEY_DOWN]

    constructor: (player) ->
      @player = player
      @highlightY = 1

    init: (song) ->
      # prevent default behavior when arrow keys are pressed
      $(document).keydown (event) =>
        if @constructor.ARROW_KEYS.indexOf(event.which) != -1
          event.preventDefault()
          false
        else
          true
    
      $(document).keyup (event) =>
        switch event.which
          when @constructor.ARROW_KEY_UP
            @moveHighlight -1
          when @constructor.ARROW_KEY_DOWN
            @moveHighlight 1
          when @constructor.ENTER_KEY
            @fillInCurrentPosition()
            @moveHighlight 1
          when @constructor.S_KEY
            @toggleSkip()
    
    loadLyricsLine: (start_time, lyric) ->
      newRow = ''
      newRow += "<tr>\n"
      newRow += "<td>#{start_time}</td>\n"
      newRow += "<td></td>\n"
      newRow += "<td>#{lyric}</td>\n"
      newRow += "</tr>\n"
      $('#js-lyrics-table > tbody').append newRow

    fillInCurrentPosition: ->
      $("#js-lyrics-table tr:nth-child(#{@highlightY + 1}) td:nth-child(1)").html(@player.getPosition())
  
    drawHighlight: (isVisible) ->
      rowSelector = "#js-lyrics-table tr:nth-child(#{@highlightY})"
      if isVisible
        $(rowSelector).addClass 'selectedRow'
      else
        $(rowSelector).removeClass 'selectedRow'

    scrollToShowHighlight: ->
      rowSelector = "#js-lyrics-table tr:nth-child(#{@highlightY})"
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
  
    moveHighlight: (yDelta) ->
      @drawHighlight false
  
      @highlightY += yDelta
      if @highlightY < 1
        @highlightY = 1
      if @highlightY > $('#js-lyrics-table tr').length
        @highlightY = $('#js-lyrics-table tr').length
   
      @drawHighlight true
      @scrollToShowHighlight()

    toggleSkip: ->
      selector = "#js-lyrics-table tr:nth-child(#{@highlightY}) td:nth-child(2)"
      existingSkip = $(selector).html()
      if existingSkip == '#'
        $(selector).html('')
      else
        $(selector).html('#')
