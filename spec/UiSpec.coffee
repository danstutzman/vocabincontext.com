define (require) ->
  $ = require('jquery')
  LyricsTableView = require('cs!app/LyricsTableView')

  simulateKeyUp = (which) ->
    keyup = $.Event('keyup', { which: which })
    $(document).trigger(keyup)

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

  describe 'LyricsTableView', ->
    it 'should advance cursor downward when down arrow key is pressed', ->
      simulateKeyUp LyricsTableView.ARROW_KEY_DOWN
      # make sure highlight is on second row
      class_ = $('#js-lyrics-table tr:nth-child(2)').attr('class')
      expect(class_).toEqual("selectedRow")
