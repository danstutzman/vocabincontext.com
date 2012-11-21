define (require) ->
  $ = require('jquery')
  soundManager = require('cs!app/soundManager')

  init = (song) -> # returns Deferred
    deferred = $.getJSON "/media/lyrics_json/#{song}.json"
    deferred.success (lines) ->
      word_to_count = {}
      for line in lines
        for word in line['lyric'].split(' ')
          word_to_count[word.toLowerCase()] ||= 0
          word_to_count[word.toLowerCase()] += 1
  
      sorted_words = Object.keys(word_to_count)
      sorted_words.sort (value1, value2) ->
        return -1 if value1 < value2
        return +1 if value1 > value2
        return 0
  
      #sort by frequency:
      #sorted_words.sort (value1, value2) ->
      #  return -1 if word_to_count[value1] < word_to_count[value2]
      #  return +1 if word_to_count[value1] > word_to_count[value2]
      #  return 0
  
      for word in sorted_words
        count = word_to_count[word]
  
        li = ''
        li += '<li>'
        li += "<a class='js-word-link' data-word='#{word}' href='#'>"
        li += "#{word}(#{count})"
        li += '</a>'
        li += '</li>'
        $('#words').append(li)
  
      $('.js-word-link').click (event) =>
        word = event.target.getAttribute('data-word')
  
        $('#lyrics').empty()
        for line in lines
          if line['lyric'].indexOf(word) != -1
            href = "/#{line['filename']}"
            li = ''
            li += '<li>'
            li += "<a id='#{line['id']}' class='js-sound-link' href='#{href}'>"
            li += line['lyric']
            li += '</a>'
            li += '</li>'
            $('#lyrics').append(li)

            $('.js-sound-link').click (event) =>
              id = event.target.id
              href = event.target.href
              soundManager.play(id, href)
              false
        false

    deferred.error (jqXHR, textStatus, errorThrown) ->
      throw new Error("Error in WordLinks.init's getJSON: #{errorThrown}")

    deferred

  { init: init }