define (require) ->
  clone = (obj) ->
    if obj == null || typeof(obj) != 'object'
      return obj
    temp = obj.constructor()
    for key of obj
      temp[key] = clone(obj[key])
    temp

  class LyricsTableData
    constructor: ->
      @_highlightY = 0 # highlighting the column headers row
      @_rows = []

    highlightY: -> @_highlightY

    rows: -> clone(@_rows)

    highlightedRow: -> clone(@_rows[@_highlightY])

    _convertStartTime: (start_time) ->
      if typeof(start_time) == 'number'
        start_time
      else if start_time == null
        null
      else if start_time == ''
        null
      else if typeof(start_time) == 'string' && start_time.match(/^[0-9]+$/)
        parseInt(start_time)
      else
        throw new Error(\
          "Invalid start_time argument: #{start_time} #{typeof(start_time)}")

    _convertLyric: (lyric) ->
      if typeof(lyric) == 'string'
        lyric
      else
        throw new Error("Invalid lyric argument: #{lyric}")

    loadLyricsLine: (start_time, lyric) ->
      start_time = @_convertStartTime(start_time)
      lyric = @_convertLyric(lyric)
      @_rows.push({
        start_time: start_time
        lyric: lyric
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
   
    setStartTime: (new_time) ->
      new_time = @_convertStartTime(new_time)
      @_rows[@_highlightY]['start_time'] = new_time

    toggleSkipOnHighlightedRow: ->
      @_rows[@_highlightY]['skip'] = !@_rows[@_highlightY]['skip']
