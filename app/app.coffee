define (require) ->
  $                = require('jquery')
  fakeSoundManager = require('cs!app/fakeSoundManager')
  realSoundManager = require('cs!app/soundManager')
  Player           = require('cs!app/Player')
  WordLinks        = require('cs!app/WordLinks')
  LyricsTableData  = require('cs!app/LyricsTableData')
  LyricsTableView  = require('cs!app/LyricsTableView')
  LyricsLoader     = require('cs!app/LyricsLoader')
  YouTubePlayer    = require('cs!app/YouTubePlayer')

  getRequestParams = ->
    result = {}
    re = /([^&=]+)=([^&]*)/g
    d = window.decodeURIComponent
    s = window.location.search
    s = if s.match /^\?/ then s.substring(1) else s
    while match = re.exec(s)
      result[d(match[1])] = d match[2]
    result

  setup = (song, soundManager, callback) ->
    waitForAll = $.Deferred().resolve()

    if song
      if $('#words').length > 0 && $('#lyrics').length > 0
        waitForAjax = WordLinks.init song
        waitForAll = waitForAll.pipe -> waitForAjax

      # add player in canvas
      if $('#player').length
        mp3Link = "/media/whole_songs/#{song}.mp3"
        player = new Player($('#player'), $, soundManager, mp3Link)
        waitForSoundManager = $.Deferred()
        soundManager.onready -> waitForSoundManager.resolve()
        waitForAll = waitForAll.pipe -> waitForSoundManager

        if $('#js-lyrics-table').length > 0
          data = new LyricsTableData()
          table = new LyricsTableView(player, data)
          table.init()
          waitForAjax = new LyricsLoader().load(song, ->
            table.loadLyricsLine.apply table, arguments)
          waitForAll = waitForAll.pipe -> waitForAjax
    else
      if $('#js-lyrics-table').length > 0
        player = new YouTubePlayer($('#myytplayer')[0])
        data = new LyricsTableData()
        for td in $('#js-lyrics-table tr td:nth-child(3)')
          data.loadLyricsLine null, $(td).text()
        table = new LyricsTableView(player, data)
        table.init()

    waitForAll.done ->
      $('#throbber-background').hide()
      $('#throbber-foreground').hide()
      callback()

  setupFromRequestParams: ->
    params = getRequestParams()
    song = params['song']
    setup song, realSoundManager, (->)

  setupForTestingAndThen: (callback) ->
    params = getRequestParams()

    song = 'testing'

    soundManager = switch params['soundManager']
      when 'fakeSoundManager' then fakeSoundManager
      when 'realSoundManager' then realSoundManager
      else
        window.alert 'You must specify a soundManager param'
        throw new Error('You must specify a soundManager param')

    setup song, soundManager, callback
