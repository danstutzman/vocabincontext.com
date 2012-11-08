define (require) ->
  $ = require('jquery')
  main = require('main')

  describe 'Player', ->
    it 'should advance cursor at least 100 pixels before 4 seconds pass', ->
      runs ->
        $('#play-button').click() # start playing
      cursorAdvances = ->
        cursor = $('#cursor')[0]
        parseInt(cursor.style.left) >= 100
      waitsFor cursorAdvances, 'cursor should advance', 4000
      runs ->
        $('#play-button').click() # stop playing
