define (require) ->
  $                = require('jquery')
  fakeSoundManager = require('cs!app/fakeSoundManager')
  realSoundManager = require('cs!app/soundManager')
  Player           = require('cs!app/Player')
  LyricsEditorView = require('cs!app/LyricsEditorView')
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

  setup = (soundManager, callback) ->
    waitForAll = $.Deferred().resolve()

    # Show loading throbber until SoundManager loads
    waitForSoundManager = $.Deferred()
    soundManager.onready -> waitForSoundManager.resolve()
    waitForAll = waitForAll.pipe -> waitForSoundManager

    if $('#js-lyrics-table').length > 0
      player = new YouTubePlayer($('#myytplayer')[0])
      table = new LyricsEditorView(player)
      table.initFromDom()

    waitForAll.done ->
      $('#throbber-background').hide()
      $('#throbber-foreground').hide()
      callback()

  setupFromRequestParams: ->
    params = getRequestParams()
    setup realSoundManager, (->)

  setupForTestingAndThen: (callback) ->
    params = getRequestParams()

    soundManager = switch params['soundManager']
      when 'fakeSoundManager' then fakeSoundManager
      when 'realSoundManager' then realSoundManager
      else
        window.alert 'You must specify a soundManager param'
        throw new Error('You must specify a soundManager param')

    setup soundManager, callback
