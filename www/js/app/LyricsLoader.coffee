define (require) ->
  $ = require('jquery')

  class LyricsLoader
    load: (song, newLineCallback) ->
      $.ajax
        url: "/media/lyrics_txt/#{song}.txt"
        success: (data, textStatus, jqXHR) =>
          for line in data.split("\n")
            @interpretDataLine line, newLineCallback
        error: (jqXHR, textStatus, errorThrown) ->
          throw errorThrown

    interpretDataLine: (line, newLineCallback) ->
      if match = line.match(/^([0-9]+)\s+(.*)$/)
        start_time = match[1]
        lyric = match[2]
      else
        start_time = ''
        lyric = line

      newLineCallback start_time, lyric
