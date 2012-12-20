define (require) ->
  $                   = require('jquery')
  fakeSoundManager    = require('cs!app/fakeSoundManager')
  realSoundManager    = require('cs!app/soundManager')
  LyricsEditorView    = require('cs!app/LyricsEditorView')
  YouTubeSound        = require('cs!app/YouTubeSound')
  YouTubePlayer       = require('cs!app/YouTubePlayer')
  ProgressBar         = require('cs!app/ProgressBar')
  Utility             = require('cs!app/Utility')
  NeedVideoPopUp      = require('cs!app/NeedVideoPopUp')
  NeedAlignmentsPopUp = require('cs!app/NeedAlignmentsPopUp')

  setup = (soundManager, callback) ->
    if $('#js-lyrics-table').length > 0
      video_id = $('#youtube-video-id').text()
      if video_id != ''
        sound = new YouTubeSound(video_id)
        sound.init()

        player = new YouTubePlayer(sound)
        player.init $('.youtube-player')

        table = new LyricsEditorView(sound)
        table.initFromDom()

        if $('.need-alignments').length
          pop_up = new NeedAlignmentsPopUp(sound)
          pop_up.init $('.need-alignments'), $('.modal-background')

    if $('.need-video').length
      pop_up = new NeedVideoPopUp()
      song_name = $('#song_name').text()
      artist_name = $('#artist_name').text()
      pop_up.init \
        $('.need-video'), $('.modal-background'), song_name, artist_name

    # enhance play buttons to stay on same page instead of loading new page
    $('.play-excerpt-mp3').each (i, button) ->
      $(button).click ->
        soundManager.onready -> # if hasn't loaded yet, wait until loaded
          sound = soundManager.createSound
            id: "sound#{i}"
            url: $(button).parent().attr('href')
            autoplay: false
          sound.play()
        false

    # enhance play buttons to stay on same page instead of loading new page
    $('.play-excerpt-youtube').each (i, button) ->
      url = $(button).parent().attr('href')
      $(button).click ->
        $('#youtube-embed').attr 'src', url
        false

    # reload the query results as soon as [] Exact Match value is changed
    $('#exact-match').click =>
      $('form').submit()
      false

    callback()

  setupFromRequestParams: ->
    params = Utility.getRequestParams()
    setup realSoundManager, (->)

  setupForTestingAndThen: (callback) ->
    params = Utility.getRequestParams()

    soundManager = switch params['soundManager']
      when 'fakeSoundManager' then fakeSoundManager
      when 'realSoundManager' then realSoundManager
      else
        window.alert 'You must specify a soundManager param'
        throw new Error('You must specify a soundManager param')

    setup soundManager, callback
