define (require) ->
  LyricsEditorModel = require('cs!app/LyricsEditorModel')

  describe 'LyricsEditorModel', ->
    it 'starts with the highlight at the top', ->
      data = new LyricsEditorModel()
      expect(data.highlightY()).toEqual 0
    it 'starts empty', ->
      data = new LyricsEditorModel()
      expect(data.rows()).toEqual []
    it 'allows loading lyrics', ->
      data = new LyricsEditorModel()
      data.loadLyricsLine 30, 'the lyrics', 70
      expect(data.rows().length).toEqual 1
      expect(data.rows()[0].start_centis).toEqual 30
      expect(data.rows()[0].lyric).toEqual 'the lyrics'
      expect(data.rows()[0].finish_centis).toEqual 70
    it 'adds second lyrics below the first', ->
      data = new LyricsEditorModel()
      data.loadLyricsLine  30, 'lyrics line 1',  70
      data.loadLyricsLine 130, 'lyrics line 2', 170
      expect(data.rows()[0].start_centis).toEqual 30
      expect(data.rows()[0].lyric).toEqual 'lyrics line 1'
      expect(data.rows()[0].finish_centis).toEqual 70
      expect(data.rows()[1].start_centis).toEqual 130
      expect(data.rows()[1].lyric).toEqual 'lyrics line 2'
      expect(data.rows()[1].finish_centis).toEqual 170
    it 'lets you move the highlight down and up', ->
      data = new LyricsEditorModel()
      data.loadLyricsLine  30, 'lyrics line 1',  70
      data.loadLyricsLine 130, 'lyrics line 2', 170
      data.moveHighlight 1
      expect(data.highlightY()).toEqual 1
      data.moveHighlight 1
      expect(data.highlightY()).toEqual 2
      data.moveHighlight -1
      expect(data.highlightY()).toEqual 1
      data.moveHighlight -1
      expect(data.highlightY()).toEqual 0
    it 'doesn\'t let you move the highlight too high', ->
      data = new LyricsEditorModel()
      data.moveHighlight -1
      expect(data.highlightY()).toEqual 0
    it 'doesn\'t let you move the highlight too low', ->
      data = new LyricsEditorModel()
      data.loadLyricsLine  30, 'lyrics line 1',  70
      data.loadLyricsLine 130, 'lyrics line 2', 170
      data.moveHighlight 1
      data.moveHighlight 1
      data.moveHighlight 1
      expect(data.highlightY()).toEqual 2
    it 'gives you access to the highlighted row', ->
      data = new LyricsEditorModel()
      data.loadLyricsLine  30, 'lyrics line 1',  70
      data.loadLyricsLine 130, 'lyrics line 2', 170
      expect(data.highlightedRow().start_centis).toEqual 30
      expect(data.highlightedRow().lyric).toEqual 'lyrics line 1'
      expect(data.highlightedRow().finish_centis).toEqual 70
      data.moveHighlight 1
      expect(data.highlightedRow().start_centis).toEqual 130
      expect(data.highlightedRow().lyric).toEqual 'lyrics line 2'
      expect(data.highlightedRow().finish_centis).toEqual 170

    it 'doesn\'t accept null lyric', ->
      data = new LyricsEditorModel()
      expect(-> data.loadLyricsLine 123, null).toThrow()

    it 'doesn\'t allow cursor movement other than 1 up or 1 down', ->
      data = new LyricsEditorModel()
      expect(-> data.moveHighlight 0).toThrow()
      expect(-> data.moveHighlight -2).toThrow()
      expect(-> data.moveHighlight 2).toThrow()
      expect(-> data.moveHighlight null).toThrow()
