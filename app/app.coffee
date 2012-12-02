define (require) ->
  $                = require('jquery')
  Utility          = require('cs!app/Utility')
  fakeSoundManager = require('cs!app/fakeSoundManager')
  realSoundManager = require('cs!app/soundManager')
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

      player.addListener 'stateChange', (event) ->
        console.log 'stateChange', event.state
        $('#progress-total-time').text \
          Utility.formatTimeMS(player.getDuration())
        $('#play-button').text player.getCurrentTogglePlayingVerb()

      updateProgressBar = (soFar, toGo) ->
        outerLength = $('#progress-outer').width()
        barLength = outerLength * soFar / toGo

        if barLength >= 40
          $('#progress-bar').text Utility.formatTimeMS(soFar) + "\u00a0\u00a0"
          $('#progress-bar-caption').text ''
        else
          $('#progress-bar').text ''
          $('#progress-bar-caption').text \
            "\u00a0\u00a0" + Utility.formatTimeMS(soFar)

        if outerLength - barLength < 40
          $('#progress-total-time').text ''
        else
          $('#progress-total-time').text Utility.formatTimeMS(toGo)

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
      $('.modal-background').hide()
      $('#throbber-foreground').hide()
      callback()

    show_popup = ->
      maskHeight = $(window).height()
      maskWidth = $(window).width()
      dialogTop = 30
      dialogLeft = maskWidth / 2 - $('.need-video').width() / 2
      $('.modal-background').css({height:maskHeight, width:maskWidth}).show()
      $('.need-video').css({top:dialogTop, left:dialogLeft}).show()

    $ ->
      $('a.button.close-button').click ->
        $('.modal-background, .need-video').hide()
        false
       
      # if user resize the window, call the same function again
      # to make sure the modal-background fills the screen and
      # dialogbox aligned to center
      $(window).resize ->
        # only do it if the dialog box is not hidden
        if (!$('.need-video').is(':hidden'))
          show_popup()
    show_popup()
 
    if $('.youtube-search-is-loading').length
      song_name = $('#song_name').text()
      artist_name = $('#artist_name').text()
      promise = $.ajax
        url: "/youtube-search/#{song_name}+#{artist_name}?no_layout=true"
      promise.done (data, text_status, jqxhr) ->
        $('.youtube-search-is-loading').replaceWith data

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
