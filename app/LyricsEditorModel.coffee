define (require) ->
  clone = (obj) ->
    if obj == null || typeof(obj) != 'object'
      return obj
    temp = obj.constructor()
    for key of obj
      temp[key] = clone(obj[key])
    temp

  class LyricsEditorModel
    constructor: ->
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
      @_highlightSize = false

      @_rows = []

    # getters
    highlightY: -> @_highlightY
    highlightSize: -> @_highlightSize
    rows: -> clone(@_rows)
    highlightedRow: -> clone(@_rows[@_highlightY])

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

    loadLyricsLine: (start_centis, lyric, finish_centis) ->
      start_centis  = @_convertCentis('start_centis', start_centis)
      finish_centis = @_convertCentis('finish_centis', finish_centis)
      lyric       = @_convertLyric(lyric)
      @_rows.push({
        start_centis: start_centis
        lyric: lyric
        finish_centis: finish_centis
        skip: false
      })

    moveHighlight: (yDelta) ->
      if yDelta != -1 && yDelta != 1
        throw new Error(\
          "Invalid argument #{yDelta} to moveHighlight: must be -1 or 1")

      @_highlightY += yDelta

      if @_highlightY < 0
        @_highlightY = 0
      if @_highlightY > @_rows.length
        @_highlightY = @_rows.length
   
#    setStartCentis: (new_centis) ->
#      new_centis = @_convertStartCentis(new_centis)
#      @_rows[@_highlightY]['start_centis'] = new_centis
