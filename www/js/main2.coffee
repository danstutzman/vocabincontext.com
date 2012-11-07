define (require) ->
  $            = require('jquery')
  soundManager = require('cs!app/soundManager')
  Player       = require('cs!app/Player')
  WordLinks    = require('cs!app/WordLinks')
  LyricsTable  = require('cs!app/LyricsTable')
  LyricsLoader = require('cs!app/LyricsLoader')

  getParams = ->
    result = {}
    re = /([^&=]+)=([^&]*)/g
    d = decodeURIComponent
    s = location.search
    s = if s.match /^\?/ then s.substring(1) else s
    while match = re.exec(s)
      result[d(match[1])] = d match[2]
    result

  soundManager.onready ->
    $('#throbber-background').hide()
    $('#throbber-foreground').hide()

  song = getParams()['song']
  if !song
    alert 'Please specify a song parameter'

  if $('#words').length > 0 && $('#lyrics').length > 0
    WordLinks.init song

  # add player in canvas
  if $('#player').length
    mp3Link = "/media/whole_songs/#{song}.mp3"
    player = new Player($('#player'), $, soundManager, mp3Link)

    if $('#js-lyrics-table').length > 0
      table = new LyricsTable(player)
      table.init()
      new LyricsLoader().load(song, table.loadLyricsLine)
