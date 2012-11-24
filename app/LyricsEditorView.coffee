define (require) ->
  $ = require('jquery')
  LyricsEditorModel = require('cs!app/LyricsEditorModel')

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

  class LyricsEditorView
    @E_KEY: 69
    @S_KEY: 83
    @D_KEY: 68
    @F_KEY: 70
    @COL_NAME_TO_COL_NUM:
      start_centis: 0
      lyric: 1
      finish_centis: 2

    constructor: (player) ->
      @_player = player
      @_model = null

    _collectRowsFromDom: ->
      rows = []
      for tr in $('#js-lyrics-table tr')
        tds = $(tr).children('td')
        if tds.length == 3
          row =
            start_centis:  parseInt($(tds[0]).children('input').attr('value'))
            lyric:         $(tds[1]).text()
            finish_centis: parseInt($(tds[2]).children('input').attr('value'))
          rows.push row
      rows

    _redrawHighlight: ->
      # erase old highlight
      $('#js-lyrics-table tr.inBetweenRow').remove()
      $('#js-lyrics-table tr.selectedRow').removeClass 'selectedRow'

      # draw new highlight
      y = @_model.highlightY()
      switch @_model.highlightSize()
        when 0
          new_tr = "<tr class='selectedRow inBetweenRow'>
              <td colspan='3'></td>
            </tr>"
          if y < @_model.numRows()
            @_highlightedRow().before(new_tr)
          else
            $('#js-lyrics-table tr:last').after(new_tr)
        when 1
          @_highlightedRow().addClass 'selectedRow'

      @_scrollToShowHighlight()

    _redrawCurrentRow: ->
      new_data = @_model.highlightedRow()
      new_start_centis = new_data.start_centis / 100.0
      new_lyric = new_data.lyric
      new_finish_centis = new_data.finish_centis / 100.0

      tds = @_highlightedRow().children('td')
      tds.eq(0).children('input').attr 'value', new_start_centis
      tds.eq(1).text new_lyric
      tds.eq(2).children('input').attr 'value', new_finish_centis

    initFromDom: ->
      @_model = new LyricsEditorModel(@_collectRowsFromDom())
      @_model.addListener 'updateHighlight', => @_redrawHighlight()
      @_model.addListener 'updateCurrentRow', => @_redrawCurrentRow()

      @_redrawHighlight()

      $(document).keyup (event) =>
        switch event.which
          when @constructor.E_KEY # Up (mnemonic: [E]arlier)
            @_model.moveHighlight -1
          when @constructor.D_KEY # [D]own
            @_model.moveHighlight 1
          when @constructor.S_KEY # this line [S]tarted
            @_model.labelStartCentis @_player.getPosition()
          when @constructor.F_KEY # this line [F]inished
            @_model.labelFinishCentis @_player.getPosition()

    _highlightedRow: ->
      # add 1 because nth-child is 1-based, add 1 because of table headers
      $("#js-lyrics-table tr:nth-child(#{@_model.highlightY() + 2})")

#    _reloadHighlightedDataForCol: (col_name) ->
#      new_data = @_data.highlightedRow()[col_name]
#      if col_name == 'skip'
#        new_data = @_dataSkipToHtml(new_data)
#
#      col_num = @constructor.COL_NAME_TO_COL_NUM[col_name]
#      selector = "#{@_highlightedRowSelector()} td:nth-child(#{col_num + 1})"
#      if col_name == 'start_time'
#        selector += " input"
#        $(selector).attr 'value', new_data
#      else
#        $(selector).html(new_data)
#
#    fillInCurrentPosition: ->
#      time = @_player.getPosition()
#      @_data.setStartTime time
#      @_reloadHighlightedDataForCol('start_time')
#
    _scrollToShowHighlight: ->
      {x, y, w, h} = objectToXY(@_highlightedRow()[0])

      scrollTop = window.pageYOffset
      if y < scrollTop
        $('body')[0].scrollTop = y

      scrollbarSize = $('.scrollbar-measure')[0].offsetWidth - \
        $('.scrollbar-measure')[0].clientWidth
      windowSize = window.innerHeight - scrollbarSize
      scrollBottom = window.pageYOffset + windowSize
      if (y + h) > scrollBottom
        $('body')[0].scrollTop = (y + h) - windowSize
