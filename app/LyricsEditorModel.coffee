define (require) ->
  EventTarget = require('cs!app/EventTarget')

  clone = (obj) ->
    if obj == null || typeof(obj) != 'object'
      return obj
    temp = obj.constructor()
    for key of obj
      temp[key] = clone(obj[key])
    temp

  class LyricsEditorModel extends EventTarget
    constructor: (rows) ->
      super()

      # 0   means starting before the first line of text
      # n-1 means starting before the last line of text
      # n   means starting after the last line of text
      #     (any musical ending that follows the last line of text)
      @_highlightY = 0

      # highlightSize = 0 means highlight precedes that line of text.
      # highlightSize = 1 means highlight encompasses that line of text.
      #
      # For example, if highlightY = 3 and highlightSize = 0:
      # 2 second line of text
      # __________________
      # ------------------  <-- (area between lines is highlighted)
      # 3 third line of text
      # 4 fourth line of text
      #
      # If highlightY = 3 and highlightSize = 1:
      # 2 second line of text
      # ____________________
      # 3 third line of text  <-- (area between lines is highlighted)
      # --------------------
      # 4 fourth line of text
      @_highlightSize = 0

      @_rows = clone(rows)

    # read-only
    highlightY: -> @_highlightY
    highlightSize: -> @_highlightSize
    rows: -> clone(@_rows)
    highlightedRow: -> clone(@_rows[@_highlightY])
    numRows: -> @_rows.length

    _convertCentis: (field_name, centis) ->
      if typeof(centis) == 'number'
        centis
      else if centis == null
        null
      else if centis == ''
        null
      else if typeof(centis) == 'string' && centis.match(/^[0-9]+$/)
        parseInt(centis)
      else
        throw new Error(\
          "Invalid #{field_name} argument: #{centis} #{typeof(centis)}")

    _convertLyric: (lyric) ->
      if typeof(lyric) == 'string'
        lyric
      else
        throw new Error("Invalid lyric argument: #{lyric}")

    _trimLastNewline: (string) ->
      if string.charAt(string.length - 1) == "\n"
        string.substring 0, string.length - 1
      else
        string

    moveHighlight: (yDelta) ->
      if yDelta != -1 && yDelta != 1
        throw new Error(\
          "Invalid argument #{yDelta} to moveHighlight: must be -1 or 1")

      @_highlightY += yDelta

      if @_highlightY < 0
        @_highlightY = 0
      if @_highlightY > @_rows.length
        @_highlightY = @_rows.length

      if @_highlightY == @_rows.length
        @_highlightSize = 0
   
      @fire 'updateHighlight'

    labelStartCentis: (new_centis) ->
      new_centis = @_convertCentis('start_centis', new_centis)

      if @_highlightSize == 0 && @_highlightY < @_rows.length
        # current row hadn't started yet; now it has

        @_highlightSize = 1
        @fire 'updateHighlight'

        @_rows[@_highlightY].start_centis = new_centis
        @fire 'updateCurrentRow'

      # pressing [S] usually marks the current line as finished and moves
      # you to the next line, but if you're on the last line already, there's
      # no new line to start.  The only thing left to do is finish the
      # current (last) line
      else if @_highlightSize == 1 && @_highlightY == @_rows.length - 1
        @labelFinishCentis new_centis

      # convenience: pressing [S] while you're in a row presses [F] for you
      else if @_highlightSize == 1
        @_rows[@_highlightY].finish_centis = new_centis
        @fire 'updateCurrentRow'

        @moveHighlight 1

        @_rows[@_highlightY].start_centis = new_centis
        @fire 'updateCurrentRow'

    labelFinishCentis: (new_centis) ->
      new_centis = @_convertCentis('finish_centis', new_centis)

      if @_highlightSize == 1
        @_rows[@_highlightY].finish_centis = new_centis
        @fire 'updateCurrentRow'

        @_highlightSize = 0
        @moveHighlight 1
