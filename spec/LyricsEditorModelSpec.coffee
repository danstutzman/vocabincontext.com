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

    it 'gives you access to the highlighted row', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      expect(model.highlightedRow().lyric).toEqual 'line 1'
      model.moveHighlight 1
      expect(model.highlightedRow().lyric).toEqual 'line 2'

    it 'doesn\'t allow cursor movement other than 1 up or 1 down', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      expect(-> model.moveHighlight 0).toThrow()
      expect(-> model.moveHighlight -2).toThrow()
      expect(-> model.moveHighlight 2).toThrow()
      expect(-> model.moveHighlight null).toThrow()

    it 'lets you set start_centis in order', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      model.labelStartCentis 123
      expect(model.rows()[0].start_centis).toEqual 123
      expect(model.rows()[1].start_centis).toEqual null

      model.labelStartCentis 234
      expect(model.rows()[0].start_centis).toEqual 123
      expect(model.rows()[1].start_centis).toEqual 234

    it 'fires updateHighlight when cursor is moved down', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])

      numFirings = 0
      model.addListener 'updateHighlight', -> numFirings += 1
      model.moveHighlight 1
      expect(numFirings).toEqual 1

    it 'fires updateHighlight when cursor is moved up', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])

      model.moveHighlight 1

      numFirings = 0
      model.addListener 'updateHighlight', -> numFirings += 1
      model.moveHighlight -1
      expect(numFirings).toEqual 1

    it 'ignores labelStartCentis when already on last line', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      model.labelStartCentis 123
      model.labelStartCentis 234
      model.labelStartCentis 345

      expect(model.rows().length).toEqual 2
      expect(model.rows()[0].start_centis).toEqual 123
      expect(model.rows()[1].start_centis).toEqual 234

    it 'lets you set finish_centis too', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])
      model.labelStartCentis 123
      model.labelFinishCentis 234
      expect(model.rows()[0].start_centis).toEqual 123
      expect(model.rows()[0].finish_centis).toEqual 234
      expect(model.rows()[1].start_centis).toEqual null
      expect(model.rows()[1].finish_centis).toEqual null

      model.labelStartCentis 345
      model.labelFinishCentis 456
      expect(model.rows()[0].start_centis).toEqual 123
      expect(model.rows()[0].finish_centis).toEqual 234
      expect(model.rows()[1].start_centis).toEqual 345
      expect(model.rows()[1].finish_centis).toEqual 456

    it 'ignores finish_centis if never started', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])

      numFirings = 0
      model.addListener 'updateHighlight', -> numFirings += 1
      model.addListener 'updateCurrentRow', -> numFirings += 1

      model.labelFinishCentis 123
      expect(numFirings).toEqual 0

    it 'ignores finish_centis if already finished', ->
      model = new LyricsEditorModel([
        { lyric: 'line 1' },
        { lyric: 'line 2' }
      ])

      model.labelStartCentis 123
      model.labelFinishCentis 234

      numFirings = 0
      model.addListener 'updateHighlight', -> numFirings += 1
      model.addListener 'updateCurrentRow', -> numFirings += 1

      model.labelFinishCentis 345
      expect(numFirings).toEqual 0

    it 'skips over blank lines', ->
      model = new LyricsEditorModel([
        { lyric: 'line 0' },
        { lyric: '' },
        { lyric: 'line 2' }
      ])
      expect(model.highlightY()).toEqual 0
      model.moveHighlight 1
      expect(model.highlightY()).toEqual 2
