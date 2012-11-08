define (require) ->
  $                = require('jquery')
  fakeSoundManager = require('cs!app/fakeSoundManager')
  realSoundManager = require('cs!app/soundManager')
  Player           = require('cs!app/Player')
  WordLinks        = require('cs!app/WordLinks')
  LyricsTable      = require('cs!app/LyricsTable')
  LyricsLoader     = require('cs!app/LyricsLoader')

  getRequestParams = ->
    result = {}
    re = /([^&=]+)=([^&]*)/g
    d = window.decodeURIComponent
    s = window.location.search
    s = if s.match /^\?/ then s.substring(1) else s
    while match = re.exec(s)
      result[d(match[1])] = d match[2]
    result

  setup = (song, soundManager) ->
    soundManager.onready ->
      $('#throbber-background').hide()
      $('#throbber-foreground').hide()

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

  setupFromRequestParams: ->
    params = getRequestParams()
    song = params['song']

    if !song
      window.alert 'Please specify a song parameter'
    else
      setup song, realSoundManager

  setupForTestingAndThen: (callback) ->
    params = getRequestParams()

    song = 'testing'

    soundManager = switch params['soundManager']
      when 'fakeSoundManager' then fakeSoundManager
      when 'realSoundManager' then realSoundManager
      else
        window.alert 'You must specify a soundManager param'
        throw new Error('You must specify a soundManager param')

    setup song, soundManager
    soundManager.onready callback
