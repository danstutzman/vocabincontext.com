define (require) ->
  TimeSeries = require('cs!app/TimeSeries').TimeSeries
  DATA_CANT_REACH_FURTHER_THAN = 500 # milliseconds

  class SoundGrid
    constructor: (w, h, duration) ->
      @w = w
      @h = h
      @duration = duration
      @timeSeries = new TimeSeries()
      @previousX = 0

    resize: (w, h) ->
      @w = w
      @h = h
      @renderStripes(0, @w - 1)

    addData: (position, energy) ->
      @timeSeries.add position, energy
      cursorX = Math.floor(@w * position / @duration)
      stripes = @renderStripes(@previousX, cursorX)
      @previousX = cursorX
      stripes

    renderStripes: (x0, x1) ->
      stripes = {}
      for x in [x0..x1]
        position = x * @duration / @w
        value = @timeSeries.getClosestValueNotFartherThan(
          position, DATA_CANT_REACH_FURTHER_THAN)
        if value != null
          height = value * @h + 0.25
          y0 = Math.floor((@h / 2) - height/2)
          y1 = y0 + height
          stripe = (
            (if (y >= y0 && y < y1) then 1.0 else 0.0) for y in [0...@h])
        else
          stripe = null
        stripes[x] = stripe
      stripes
