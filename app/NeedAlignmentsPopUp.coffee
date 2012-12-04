define (require) ->
  $     = require('jquery')
  PopUp = require('cs!app/PopUp')

  class NeedAlignmentsPopUp extends PopUp
    init: ($dialog, $background, song_name, artist_name) ->
      super.init $dialog, $background
