define (require) ->
  $ = require('jquery')

  class PopUp
    init: ($dialog, $background) ->
      @$dialog = $dialog
      @$background = $background

      @$dialog.find('a.button.close-button').click =>
        @$dialog.hide()
        @$background.hide()
        false
       
      # if user resizes the window, call the same function again
      # to make sure the modal-background fills the screen and
      # dialogbox aligned to center
      $(window).resize =>
        @_show_popup() if @$dialog.is(':visible')

      @_show_popup()

    _show_popup: ->
      maskHeight = $(window).height()
      maskWidth = $(window).width()
      dialogTop = 30
      dialogLeft = maskWidth / 2 - @$dialog.width() / 2
      @$background.css({height:maskHeight, width:maskWidth}).show()
      @$dialog.css({top:dialogTop, left:dialogLeft}).show()
