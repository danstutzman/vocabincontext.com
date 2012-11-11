define (require) ->
  LyricsTableData = require('cs!app/LyricsTableData')

  describe 'LyricsTableData', ->
    it 'starts with the highlight at the top', ->
      data = new LyricsTableData()
      expect(data.highlightY()).toEqual 0
    it 'starts empty', ->
      data = new LyricsTableData()
      expect(data.rows()).toEqual []
    it 'allows loading lyrics', ->
      data = new LyricsTableData()
      data.loadLyricsLine 123, 'the lyrics'
      expect(data.rows().length).toEqual 1
      expect(data.rows()[0].start_time).toEqual 123
      expect(data.rows()[0].lyric).toEqual 'the lyrics'
    it 'defaults loading lyrics to non-skip', ->
      data = new LyricsTableData()
      data.loadLyricsLine 123, 'the lyrics'
      expect(data.rows()[0].skip).toEqual false
    it 'adds second lyrics below the first', ->
      data = new LyricsTableData()
      data.loadLyricsLine 123, 'lyrics line 1'
      data.loadLyricsLine 234, 'lyrics line 2'
      expect(data.rows()[0].start_time).toEqual 123
      expect(data.rows()[0].lyric).toEqual 'lyrics line 1'
      expect(data.rows()[1].start_time).toEqual 234
      expect(data.rows()[1].lyric).toEqual 'lyrics line 2'
    it 'lets you move the highlight down and up', ->
      data = new LyricsTableData()
      data.loadLyricsLine 123, 'lyrics line 1'
      data.loadLyricsLine 234, 'lyrics line 2'
      data.moveHighlight 1
      expect(data.highlightY()).toEqual 1
      data.moveHighlight 1
      expect(data.highlightY()).toEqual 2
      data.moveHighlight -1
      expect(data.highlightY()).toEqual 1
      data.moveHighlight -1
      expect(data.highlightY()).toEqual 0
    it 'doesn\'t let you move the highlight too high', ->
      data = new LyricsTableData()
      data.moveHighlight -1
      expect(data.highlightY()).toEqual 0
    it 'doesn\'t let you move the highlight too low', ->
      data = new LyricsTableData()
      data.loadLyricsLine 123, 'lyrics line 1'
      data.loadLyricsLine 234, 'lyrics line 2'
      data.moveHighlight 1
      data.moveHighlight 1
      data.moveHighlight 1
      expect(data.highlightY()).toEqual 2
    it 'gives you access to the highlighted row', ->
      data = new LyricsTableData()
      data.loadLyricsLine 123, 'lyrics line 1'
      data.loadLyricsLine 234, 'lyrics line 2'
      expect(data.highlightedRow().start_time).toEqual 123
      expect(data.highlightedRow().lyric).toEqual 'lyrics line 1'
      data.moveHighlight 1
      expect(data.highlightedRow().start_time).toEqual 234
      expect(data.highlightedRow().lyric).toEqual 'lyrics line 2'
    it 'lets you toggle skip', ->
      data = new LyricsTableData()
      data.loadLyricsLine 123, 'lyrics line 1'
      expect(data.rows()[0].skip).toEqual false
      data.toggleSkipOnHighlightedRow()
      expect(data.rows()[0].skip).toEqual true
      data.toggleSkipOnHighlightedRow()
      expect(data.rows()[0].skip).toEqual false
    it 'doesn\'t accept weird start time', ->
      data = new LyricsTableData()
      expect(-> data.loadLyricsLine 'weird', 'lyrics line 1').toThrow()
    it 'converts string start time to int', ->
      data = new LyricsTableData()
      data.loadLyricsLine '123', 'lyrics line 1'
      expect(data.rows()[0].start_time).toEqual 123
    it 'accepts null start time', ->
      data = new LyricsTableData()
      data.loadLyricsLine null, 'lyrics line 1'
      expect(data.rows()[0].start_time).toEqual null
    it 'doesn\'t accept null lyric', ->
      data = new LyricsTableData()
      expect(-> data.loadLyricsLine 123, null).toThrow()
    it 'doesn\'t allow cursor movement other than up or down', ->
      data = new LyricsTableData()
      expect(-> data.moveHighlight 0).toThrow()
      expect(-> data.moveHighlight -2).toThrow()
      expect(-> data.moveHighlight 2).toThrow()
      expect(-> data.moveHighlight null).toThrow()
