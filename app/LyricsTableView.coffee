define (require) ->
  $ = require('jquery')
  LyricsTableData = require('cs!app/LyricsTableData')

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

  class LyricsTableView
    @ARROW_KEY_UP: 38
    @ARROW_KEY_DOWN: 40
    @ENTER_KEY: 13
    @S_KEY: 83
    @ARROW_KEYS: [@ARROW_KEY_UP, @ARROW_KEY_DOWN]
    @COL_NAME_TO_COL_NUM:
      start_time: 0
      skip: 1
      lyric: 2

    constructor: (player, data) ->
      @_player = player
      @_data = data

    init: ->
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
            @_drawHighlight false
            @_data.moveHighlight -1
            @_drawHighlight true
            @_scrollToShowHighlight()
          when @constructor.ARROW_KEY_DOWN
            @_drawHighlight false
            @_data.moveHighlight 1
            @_drawHighlight true
            @_scrollToShowHighlight()
          when @constructor.ENTER_KEY
            @_drawHighlight false
            @_data.moveHighlight 1
            @fillInCurrentPosition()
            @_drawHighlight true
            @_scrollToShowHighlight()
          when @constructor.S_KEY
            @toggleSkip()
    
    loadLyricsLine: (start_time, lyric) ->
      @_data.loadLyricsLine start_time, lyric
      newRow = ''
      newRow += "<tr>\n"
      newRow += "<td>#{start_time}</td>\n"
      newRow += "<td></td>\n"
      newRow += "<td>#{lyric}</td>\n"
      newRow += "</tr>\n"
      $('#js-lyrics-table > tbody').append newRow

    _highlightedRowSelector: ->
      "#js-lyrics-table tr:nth-child(#{@_data.highlightY() + 1})"

    _dataSkipToHtml: (data_skip) ->
      if data_skip then "#" else ""

    _highlightedRowForColSelector: (col_num) ->

    _reloadHighlightedDataForCol: (col_name) ->
      new_data = @_data.highlightedRow()[col_name]
      if col_name == 'skip'
        new_data = @_dataSkipToHtml(new_data)
      
      col_num = @constructor.COL_NAME_TO_COL_NUM[col_name]
      selector = "#{@_highlightedRowSelector()} td:nth-child(#{col_num + 1})"
      $(selector).html(new_data)

    fillInCurrentPosition: ->
      time = @_player.getPosition()
      @_data.setStartTime time
      @_reloadHighlightedDataForCol('start_time')
  
    _drawHighlight: (isVisible) ->
      rowSelector = @_highlightedRowSelector()
      if isVisible
        $(rowSelector).addClass 'selectedRow'
      else
        $(rowSelector).removeClass 'selectedRow'

    _scrollToShowHighlight: ->
      rowSelector = @_highlightedRowSelector()
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
  
    toggleSkip: ->
      existingSkip = @_data.highlightedRow()['skip']
      @_data.toggleSkipOnHighlightedRow()
      @_reloadHighlightedDataForCol('skip')
