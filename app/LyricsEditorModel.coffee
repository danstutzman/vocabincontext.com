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

    _convertTime: (field_name, time) ->
      if typeof(time) == 'number'
        time
      else if time == null
        null
      else if time == ''
        null
      else if typeof(time) == 'string' && time.match(/^[0-9]+$/)
        parseInt(time)
      else
        throw new Error(\
          "Invalid #{field_name} argument: #{time} #{typeof(time)}")

    _convertLyric: (lyric) ->
      if typeof(lyric) == 'string'
        lyric
      else
        throw new Error("Invalid lyric argument: #{lyric}")

    loadLyricsLine: (start_time, lyric, finish_time) ->
      start_time  = @_convertTime('start_time', start_time)
      finish_time = @_convertTime('finish_time', finish_time)
      lyric       = @_convertLyric(lyric)
      @_rows.push({
        start_time: start_time
        lyric: lyric
        finish_time: finish_time
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
   
#    setStartTime: (new_time) ->
#      new_time = @_convertStartTime(new_time)
#      @_rows[@_highlightY]['start_time'] = new_time
