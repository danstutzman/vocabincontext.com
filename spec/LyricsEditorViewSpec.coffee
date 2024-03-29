define (require) ->
  $                = require('jquery')
  LyricsEditorView = require('cs!app/LyricsEditorView')

  class FakePlayer
    constructor: ->
      @_i = 0
    getPosition: ->
      @_i += 1
      @_i

  describe 'LyricsEditorView', ->
    it 'can init with blank table', ->
      view = new LyricsEditorView(new FakePlayer())
      view.initFromDom()
      expect(view._model.rows()).toEqual []

    it 'can read from table in DOM', ->
      appendHeaders = ->
        html = ''
        html += "<tr>"
        html += "<th>start_centis</th>"
        html += "<th>lyric</th>"
        html += "<th>finish_centis</th>"
        html += "</tr>"
        $('#js-lyrics-table').append(html)

      appendRow = (line_num, start_centis, lyric, finish_centis) ->
        html = ''
        html += "<tr id='line#{line_num}'>"
        html += "<td><input value='#{start_centis}'/></td>"
        html += "<td>#{lyric}</td>"
        html += "<td><input value='#{finish_centis}'/></td>"
        html += "</tr>"
        $('#js-lyrics-table').append(html)

      #appendHeaders()
      appendRow 0,  30, 'line1',  70
      appendRow 1, 130, 'line2', 170

      view = new LyricsEditorView(new FakePlayer())
      view.initFromDom()

      expect(view._model.rows()).toEqual [
        { start_centis: 30,  lyric: 'line1', finish_centis:  70, },
        { start_centis: 130, lyric: 'line2', finish_centis: 170, },
      ]
