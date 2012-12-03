define (require) ->

  formatTimeMS: (numCentis) ->
    return '' if numCentis == null
    numSeconds = Math.round(numCentis / 100)
    mins = Math.floor(numSeconds / 60)
    secs = Math.round(numSeconds - (mins * 60))
    secs = if secs >= 10 then secs else "0#{secs}"
    "#{mins}:#{secs}"

  formatTimeMSC: (numCentis) ->
    return '' if numCentis == null
    mins = Math.floor(numCentis / 6000)
    secs = (numCentis - (mins * 6000)) / 100
    secsFixed = secs.toFixed(2)
    secsFixed = if secs >= 10 then secsFixed else "0#{secsFixed}"
    "#{mins}:#{secsFixed}"

  getRequestParams: ->
    result = {}
    re = /([^&=]+)=([^&]*)/g
    d = window.decodeURIComponent
    s = window.location.search
    s = if s.match /^\?/ then s.substring(1) else s
    while match = re.exec(s)
      result[d(match[1])] = d match[2]
    result

  objectToXY: (object) ->
    if object.offsetParent
      x = 0
      y = 0
      parent = object
      while parent
        x += parent.offsetLeft
        y += parent.offsetTop
        parent = parent.offsetParent
      { x:x, y:y, w:object.offsetWidth, h:object.offsetHeight }
