{ requirejs } = require('./test_helper')
requirejs ['cs!app/SoundGrid'], (SoundGrid) ->
  describe 'SoundGrid', ->

    it 'should start off blank', ->
      grid = new SoundGrid(1, 10, 100)
      stripes = grid.resize 1, 10
      expect(stripes).toEqual
        0 : null

    it 'should be blank except middle line for silence', ->
      grid = new SoundGrid(1, 10, 100)
      stripes = grid.addData 0, 0
      expect(stripes).toEqual
        0 : [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 ]

    it 'should be half full for 50% energy', ->
      grid = new SoundGrid(1, 10, 100)
      stripes = grid.addData 0, 0.5
      expect(stripes).toEqual
        0 : [ 0, 0, 1, 1, 1, 1, 1, 1, 0, 0 ]

    it 'should be full for 100% energy', ->
      grid = new SoundGrid(1, 10, 100)
      stripes = grid.addData 0, 1
      expect(stripes).toEqual
        0 : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ]

    it 'should translate position to x coordinate', ->
      grid = new SoundGrid(2, 10, 100)
      grid.addData 0, 0.2
      stripes = grid.addData 50, 0.4
      expect(stripes).toEqual
        0 : [ 0, 0, 0, 1, 1, 1, 0, 0, 0, 0 ]
        1 : [ 0, 0, 1, 1, 1, 1, 1, 0, 0, 0 ]
