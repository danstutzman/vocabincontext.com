define (require) ->
  LyricsEditorModel = require('cs!app/LyricsEditorModel')

  describe 'LyricsEditorModel', ->
    it 'starts with the highlight at the top and not encompassing text', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      expect(model.highlightY()).toEqual 0
      expect(model.highlightSize()).toEqual 0

    it 'lets you move the highlight down and up', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      expect(model.highlightY()).toEqual 0
      model.moveHighlight 1
      expect(model.highlightY()).toEqual 1
      model.moveHighlight 1
      expect(model.highlightY()).toEqual 2
      model.moveHighlight -1
      expect(model.highlightY()).toEqual 1
      model.moveHighlight -1
      expect(model.highlightY()).toEqual 0

    it 'doesn\'t let you move the highlight too high', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      model.moveHighlight -1
      expect(model.highlightY()).toEqual 0

    it 'doesn\'t let you move the highlight too low', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      model.moveHighlight 1
      model.moveHighlight 1
      model.moveHighlight 1
      expect(model.highlightY()).toEqual 2

#    it 'gives you access to the highlighted row', ->
#      model = new LyricsEditorModel()
#      model.loadLyricsLine  30, 'lyrics line 1',  70
#      model.loadLyricsLine 130, 'lyrics line 2', 170
#      expect(model.highlightedRow().start_centis).toEqual 30
#      expect(model.highlightedRow().lyric).toEqual 'lyrics line 1'
#      expect(model.highlightedRow().finish_centis).toEqual 70
#      model.moveHighlight 1
#      expect(model.highlightedRow().start_centis).toEqual 130
#      expect(model.highlightedRow().lyric).toEqual 'lyrics line 2'
#      expect(model.highlightedRow().finish_centis).toEqual 170
#
#    it 'doesn\'t accept null lyric', ->
#      model = new LyricsEditorModel()
#      expect(-> model.loadLyricsLine 123, null).toThrow()
#
#    it 'doesn\'t allow cursor movement other than 1 up or 1 down', ->
#      model = new LyricsEditorModel()
#      expect(-> model.moveHighlight 0).toThrow()
#      expect(-> model.moveHighlight -2).toThrow()
#      expect(-> model.moveHighlight 2).toThrow()
#      expect(-> model.moveHighlight null).toThrow()
