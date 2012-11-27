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
    @SPACE_KEY: 32
    @KEYS_TO_OVERRIDE = [@SPACE_KEY]

    @START_CENTIS_COL = 0
    @LYRIC_COL = 2
    @FINISH_CENTIS_COL = 4
    @NUM_COLS = 5

    constructor: (player) ->
      @_player = player
      @_model = null

    _readRowsOffDom: ->
      rows = []
      for tr in $('#js-lyrics-table tr')
        tds = $(tr).children('td')
        if tds.length == @constructor.NUM_COLS
          td1 = $(tds[@constructor.START_CENTIS_COL])
          td2 = $(tds[@constructor.LYRIC_COL])
          td3 = $(tds[@constructor.FINISH_CENTIS_COL])
          row =
            start_centis:  parseInt(td1.children('input').attr('value'))
            lyric:         td2.text()
            finish_centis: parseInt(td3.children('input').attr('value'))
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
              <td colspan='#{@constructor.NUM_COLS}'></td>
            </tr>"
          if y < @_model.numRows()
            @_highlightedRow().before(new_tr)
          else
            $('#js-lyrics-table tr:last').after(new_tr)
        when 1
          @_highlightedRow().addClass 'selectedRow'

      @_scrollToShowHighlight()

    _redrawRow: (event) ->
      tds = $("#line#{event.line_num}").children('td')

      if event.start_centis != undefined
        new_start_centis = event.start_centis / 100.0
        td = tds.eq(@constructor.START_CENTIS_COL)
        td.children('input').attr 'value', new_start_centis

      if event.lyric != undefined
        new_lyric = event.lyric
        td = tds.eq(@constructor.LYRIC_COL)
        td.text new_lyric

      if event.finish_centis != undefined
        new_finish_centis = event.finish_centis / 100.0
        td = tds.eq(@constructor.FINISH_CENTIS_COL)
        td.children('input').attr 'value', new_finish_centis

    initFromDom: ->
      @_model = new LyricsEditorModel(@_readRowsOffDom())
      @_model.addListener 'updateHighlight', => @_redrawHighlight()
      @_model.addListener 'updateRow', (event) => @_redrawRow(event)

      @_redrawHighlight()

      $(document).keyup (event) =>
        switch event.which
          when @constructor.E_KEY # Up (mnemonic: [E]arlier)
            @_model.moveHighlight -1

          when @constructor.D_KEY # [D]own
            @_model.moveHighlight 1

          when @constructor.S_KEY # this line [S]tarted
            if event.shiftKey
              @_model.correctStartCentis @_player.getPosition()
            else
              @_model.labelStartCentis @_player.getPosition()

          when @constructor.F_KEY # this line [F]inished
            if event.shiftKey
              @_model.correctFinishCentis @_player.getPosition()
            else
              @_model.labelFinishCentis @_player.getPosition()

          when @constructor.SPACE_KEY # start/stop player
            @_player.toggleIsPlaying()

      # in order to prevent default behavior, we have to catch the keydown
      # not just the keyup
      $(document).keydown (event) =>
        if @constructor.KEYS_TO_OVERRIDE.indexOf(event.which) != -1
          event.preventDefault()
          false
        else
          true

    _highlightedRow: ->
      $("#line#{@_model.highlightY()}")

    _scrollToShowHighlight: ->
      tr = @_highlightedRow()
      if tr.length > 0
        {x, y, w, h} = objectToXY(tr[0])

        scrollTop = window.pageYOffset
        if y < scrollTop
          $('body')[0].scrollTop = y

        scrollbarSize = $('.scrollbar-measure')[0].offsetWidth - \
          $('.scrollbar-measure')[0].clientWidth
        windowSize = window.innerHeight - scrollbarSize
        scrollBottom = window.pageYOffset + windowSize
      if (y + h) > scrollBottom
        $('body')[0].scrollTop = (y + h) - windowSize
