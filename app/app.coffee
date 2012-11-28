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
      player = new YouTubePlayer()
      $ ->
        videoId = $('#ytapiplayer').attr('data-video-id')
        player.init 'ytapiplayer', 'myytplayer', videoId

      table = new LyricsEditorView(player)
      table.initFromDom()

      $('#play-button').click ->
        player.toggleIsPlaying()
        false

      formatTime = (numCentis) ->
        numSeconds = Math.round(numCentis / 100)
        mins = Math.floor(numSeconds / 60)
        secs = Math.round(numSeconds - (mins * 60))
        secs = if secs >= 10 then secs else "0#{secs}"
        "#{mins}:#{secs}"

      player.addListener 'stateChange', (event) ->
        console.log 'stateChange', event.state
        $('#progress-total-time').text formatTime(player.getDuration())
        $('#play-button').text player.getCurrentTogglePlayingVerb()

      updateProgressBar = (soFar, toGo) ->
        outerLength = $('#progress-outer').width()
        barLength = outerLength * soFar / toGo

        if barLength >= 40
          $('#progress-bar').text formatTime(soFar) + "\u00a0\u00a0"
          $('#progress-bar-caption').text ''
        else
          $('#progress-bar').text ''
          $('#progress-bar-caption').text "\u00a0\u00a0" + formatTime(soFar)

        if outerLength - barLength < 40
          $('#progress-total-time').text ''
        else
          $('#progress-total-time').text formatTime(toGo)

        $('#progress-bar').width Math.round(barLength)
        $('#progress-bar-caption').css 'margin-left', Math.round(barLength)

        percent = player.getVideoLoadedFraction()
        $('#progress-loaded-bar').width (outerLength * percent) - barLength

      inProgressDrag = false
      player.addListener 'updateProgress', ->
        unless inProgressDrag || player.getPosition() == null
          updateProgressBar player.getPosition(), player.getDuration()

      doSeek = (inDrag) ->
        (event) ->
          inProgressDrag = inDrag
          x = event.pageX - $('#progress-outer')[0].offsetLeft
          position = x * player.getDuration() / $('#progress-outer').width()
          updateProgressBar position, player.getDuration()
          player.seekTo position, !inDrag
      draggingSeek = doSeek(true)
      doneDraggingSeek = doSeek(false)
      $('#progress-outer').mousedown (event) ->
        draggingSeek(event)
        $('#progress-outer').mousemove draggingSeek
        doneDragging = (event) ->
          $('#progress-outer').unbind 'mousemove', draggingSeek
          $('body').unbind 'mouseup', doneDragging
          doneDraggingSeek(event)
        $('body').mouseup doneDragging

      pulsationCounter = 0
      pulsate = ->
        $('tr.selectedRow').removeClass "stage#{pulsationCounter}"
        $('tr.selectedRowTop').removeClass "stage#{pulsationCounter}"
        pulsationCounter = (pulsationCounter + 1) % 4
        $('tr.selectedRow').addClass "stage#{pulsationCounter}"
        $('tr.selectedRowTop').addClass "stage#{pulsationCounter}"
      window.setInterval pulsate, 200

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
