define (require) ->
  $                 = require('jquery')
  Utility           = require('cs!app/Utility')
  LyricsEditorModel = require('cs!app/LyricsEditorModel')

  class LyricsEditorView
    @LOWER_E_KEY: 101
    @LOWER_S_KEY: 115
    @UPPER_S_KEY: 83
    @LOWER_D_KEY: 100
    @LOWER_F_KEY: 102
    @UPPER_F_KEY: 70
    @SPACE_KEY: 32
    @KEYS_TO_OVERRIDE = [@SPACE_KEY]

    @START_CENTIS_COL = 0
    @LYRIC_COL = 1
    @FINISH_CENTIS_COL = 2
    @NUM_COLS = 3

    constructor: (sound) ->
      @_sound = sound
      @_model = null

    _readRowsOffDom: ->
      rows = []
      for tr in $('#js-lyrics-table tr')
        tds = $(tr).children('td')
        if tds.length == @constructor.NUM_COLS &&
           !$(tr).hasClass('extra-blank-line')
          td1 = $(tds[@constructor.START_CENTIS_COL])
          td2 = $(tds[@constructor.LYRIC_COL])
          td3 = $(tds[@constructor.FINISH_CENTIS_COL])
          row =
            start_centis:  parseInt(td1.children('input').attr('value'))
            lyric:         $.trim(td2.text())
            finish_centis: parseInt(td3.children('input').attr('value'))
          rows.push row
      rows

    _redrawHighlight: ->
      # erase old highlight
      $('#js-lyrics-table tr.inBetweenRow').remove()
      $('#js-lyrics-table tr.selectedRow').removeClass 'selectedRow'
      $('#js-lyrics-table tr.selectedRowTop').removeClass 'selectedRowTop'

      # draw new highlight
      y = @_model.highlightY()
      switch @_model.highlightSize()
        when 0
          @_highlightedRow().addClass 'selectedRowTop'
        when 1
          @_highlightedRow().addClass 'selectedRow'

      @_scrollToShowHighlight()

    _redrawRow: (event) ->
      tds = $("#line#{event.line_num}").children('td')

      if event.start_centis != undefined
        new_start_centis = Utility.formatTimeMSC(event.start_centis)
        td = tds.eq(@constructor.START_CENTIS_COL)
        td.children('input').attr 'value', new_start_centis

      if event.lyric != undefined
        new_lyric = event.lyric
        td = tds.eq(@constructor.LYRIC_COL)
        td.text new_lyric

      if event.finish_centis != undefined
        new_finish_centis = Utility.formatTimeMSC(event.finish_centis)
        td = tds.eq(@constructor.FINISH_CENTIS_COL)
        td.children('input').attr 'value', new_finish_centis

    initFromDom: ->
      @_model = new LyricsEditorModel(@_readRowsOffDom())
      @_model.addListener 'updateHighlight', => @_redrawHighlight()
      @_model.addListener 'updateRow', (event) => @_redrawRow(event)

      @_redrawHighlight()

      pulsationCounter = 0
      pulsate = ->
        $('tr.selectedRow').removeClass "stage#{pulsationCounter}"
        $('tr.selectedRowTop').removeClass "stage#{pulsationCounter}"
        pulsationCounter = (pulsationCounter + 1) % 4
        $('tr.selectedRow').addClass "stage#{pulsationCounter}"
        $('tr.selectedRowTop').addClass "stage#{pulsationCounter}"
      window.setInterval pulsate, 200

      $(document).keypress (event) =>
        switch event.which
          when @constructor.LOWER_E_KEY # Up (mnemonic: [E]arlier)
            @_model.moveHighlight -1
            if @_model.highlightedRow().start_centis
              @_sound.seekTo @_model.highlightedRow().start_centis, false

          when @constructor.LOWER_D_KEY # [D]own
            @_model.moveHighlight 1
            if @_model.highlightedRow()?.start_centis
              @_sound.seekTo @_model.highlightedRow().start_centis, false

          when @constructor.LOWER_S_KEY # this line [S]tarted
            @_model.labelStartCentis @_sound.getPosition()

          when @constructor.UPPER_S_KEY
            @_model.correctStartCentis @_sound.getPosition()

          when @constructor.LOWER_F_KEY # this line [F]inished
            @_model.labelFinishCentis @_sound.getPosition()

          when @constructor.UPPER_F_KEY
            @_model.correctFinishCentis @_sound.getPosition()

      # keypress doesn't work for space bar
      $(document).keyup (event) =>
        switch event.which
          when @constructor.SPACE_KEY # start/stop sound
            @_sound.toggleIsPlaying()

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
        {x, y, w, h} = Utility.objectToXY(tr[0])

        scrollTop = window.pageYOffset
        if y < scrollTop
          $('body')[0].scrollTop = y

        scrollbarSize = $('.scrollbar-measure')[0].offsetWidth - \
          $('.scrollbar-measure')[0].clientWidth
        windowSize = window.innerHeight - scrollbarSize
        scrollBottom = window.pageYOffset + windowSize
      if (y + h) > scrollBottom
        $('body')[0].scrollTop = (y + h) - windowSize
