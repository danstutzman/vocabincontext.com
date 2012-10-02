define (require) ->
  TimeSeries = require('cs!app/TimeSeries').TimeSeries

  class SoundGrid
    constructor: (w, h) ->
      @w = w
      @h = h
      @timeSeries = new TimeSeries()
      @previousX = 0

    resize: (w, h) ->
      @w = w
      @h = h
      @renderStripes(0, @w - 1)

    addData: (position, energy) ->
      @timeSeries.add position, energy
      cursorX = Math.floor(@w * position)
      stripes = @renderStripes(@previousX, cursorX)
      @previousX = cursorX
      stripes

    renderStripes: (x0, x1) ->
      stripes = {}
      for x in [x0..x1]
        position = x / @w
        height = @timeSeries.getClosestValue(position) * @h + 0.25
        y0 = Math.floor((@h / 2) - height/2)
        y1 = y0 + height
        stripe = (
          (if (y >= y0 && y < y1) then 1.0 else 0.0) for y in [0...@h])
        stripes[x] = stripe
      stripes
