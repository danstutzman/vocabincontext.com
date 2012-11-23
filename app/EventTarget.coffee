define (require) ->
  class EventTarget
    constructor: ->
      @_listeners = {}

    addListener: (event_name, listener) ->
      if typeof @_listeners[event_name] == 'undefined'
        @_listeners[event_name] = []
      @_listeners[event_name].push listener
      null

    fire: (event) ->
      if typeof event == 'string'
        event = { name: event }
      if !event.target
        event.target = this
      if !event.name # if it's falsy
        throw new Error("Event object missing 'name' property.")

      if @_listeners[event.name] instanceof Array
        for listener in @_listeners[event.name]
          listener.call this, event
      null

    removeListener: (event_name, listener_to_remove) ->
      if @_listeners[event_name] instanceof Array
        listeners = @_listeners[event_name]
        for listener, i in listeners
          if listener == listener_to_remove
             listeners.splice i, 1
             break
      null
