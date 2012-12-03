define (require) ->
  $     = require('jquery')
  PopUp = require('cs!app/PopUp')

  class NeedVideoPopUp extends PopUp
    init: ($dialog, $background, song_name, artist_name) ->
      super.init $dialog, $background

      song_name = $('#song_name').text()
      artist_name = $('#artist_name').text()
      promise = $.ajax
        url: "/youtube-search/#{song_name}+#{artist_name}?no_layout=true"
      promise.done (data, text_status, jqxhr) ->
        $dialog.find('.youtube-search-is-loading').replaceWith data
