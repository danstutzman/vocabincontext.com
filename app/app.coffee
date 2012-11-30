define (require) ->
  $                = require('jquery')
  Utility          = require('cs!app/Utility')
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
      $('#throbber-background').hide()
      $('#throbber-foreground').hide()
      callback()

    $ ->
      input = $('.query-input')[0]
      input.focus() if input

    `$(document).ready(function () {
 
      // if user clicked on button, the overlay layer or the dialogbox, close the dialog  
      $('a.btn-ok, #dialog-overlay, #dialog-box').click(function () {     
          $('#dialog-overlay, #dialog-box').hide();       
          return false;
      });
       
      // if user resize the window, call the same function again
      // to make sure the overlay fills the screen and dialogbox aligned to center    
      $(window).resize(function () {
           
          //only do it if the dialog box is not hidden
          if (!$('#dialog-box').is(':hidden')) popup();       
      }); 
    var song_title = $('title').text();
    popup("<p>We don't have a recording of <i>" + song_title + "</i> yet, but it might be on YouTube.  Do you see it below?</p>");
});
 
//Popup dialog
function popup(message) {
         
    // get the screen height and width  
    var maskHeight = $(window).height();  
    var maskWidth = $(window).width();
     
    // calculate the values for center alignment
    var dialogTop =  (maskHeight/3) - ($('#dialog-box').height());  
    var dialogLeft = (maskWidth/2) - ($('#dialog-box').width()/2); 
     
    // assign values to the overlay and dialog box
    $('#dialog-overlay').css({height:maskHeight, width:maskWidth}).show();
    $('#dialog-box').css({top:dialogTop, left:dialogLeft}).show();
     
    // display the message
    $('#dialog-message').html(message);
             
}`

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
