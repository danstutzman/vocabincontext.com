define (require) ->
  formatTimeMS: (numCentis) ->
    numSeconds = Math.round(numCentis / 100)
    mins = Math.floor(numSeconds / 60)
    secs = Math.round(numSeconds - (mins * 60))
    secs = if secs >= 10 then secs else "0#{secs}"
    "#{mins}:#{secs}"

  formatTimeMSC: (numCentis) ->
    mins = Math.floor(numCentis / 6000)
    secs = (numCentis - (mins * 6000)) / 100
    secsFixed = secs.toFixed(2)
    secsFixed = if secs >= 10 then secsFixed else "0#{secsFixed}"
    "#{mins}:#{secsFixed}"
