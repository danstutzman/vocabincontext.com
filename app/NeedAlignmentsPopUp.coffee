define (require) ->
  $     = require('jquery')
  PopUp = require('cs!app/PopUp')

  class NeedAlignmentsPopUp extends PopUp
    @SPACE_KEY: 32
    @LOWER_S_KEY: 115

    constructor: (sound) ->
      @_sound = sound
      @stepNumber = 1

    init: ($dialog, $background, song_name, artist_name) ->
      super.init $dialog, $background

      # keypress doesn't work for space bar
      $(document).keyup (event) =>
        if event.which == @constructor.SPACE_KEY && @stepNumber == 1
          @_sound.startPlayingImmediately()
          $dialog.find('.step1').hide()
          $dialog.find('.step2').show()
          @stepNumber = 2
          true
        else
          true

      $(document).keypress (event) =>
        if event.which == @constructor.LOWER_S_KEY && @stepNumber == 2
          $dialog.find('.step2').hide()
          $dialog.find('.step3').show()
          @stepNumber = 3

          hideDialog = ->
            $dialog.fadeOut(500)
            $background.fadeOut(500)
          window.setTimeout hideDialog, 3000
        else
          true
