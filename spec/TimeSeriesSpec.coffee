define (require) ->
  { findClosest, TimeSeries } = require('cs!app/TimeSeries')

  describe 'findClosest', ->
    it 'should work with 0-sized arrays', ->
      expect(findClosest(3, [])).toEqual(null)
    it 'should work with 1-sized arrays when element in list', ->
      expect(findClosest(3, [3])).toEqual(3)
    it 'should work with 1-sized arrays when element not in list', ->
      expect(findClosest(3, [2])).toEqual(2)
      expect(findClosest(3, [4])).toEqual(4)
    it 'should work with 2-sized arrays when element in list', ->
      expect(findClosest(3, [0, 3])).toEqual(3)
      expect(findClosest(3, [3, 3])).toEqual(3)
      expect(findClosest(3, [3, 6])).toEqual(3)
    it 'should work with 2-sized arrays when element not in list', ->
      expect(findClosest(3, [0, 2])).toEqual(2)
      expect(findClosest(3, [2, 4])).toEqual(2)
      expect(findClosest(3, [4, 6])).toEqual(4)
    it 'should work with 3-sized arrays when element in list', ->
      expect(findClosest(3, [1, 2, 3])).toEqual(3)
      expect(findClosest(3, [2, 3, 4])).toEqual(3)
      expect(findClosest(3, [3, 4, 5])).toEqual(3)
    it 'should work with 3-sized arrays when element not in list', ->
      expect(findClosest(6, [1, 3, 5])).toEqual(5)
      expect(findClosest(6, [3, 5, 7])).toEqual(5)
      expect(findClosest(6, [5, 7, 9])).toEqual(5)
      expect(findClosest(6, [7, 9, 11])).toEqual(7)
    it 'should work with 4-sized arrays when element in list', ->
      expect(findClosest(3, [0, 1, 2, 3])).toEqual(3)
      expect(findClosest(3, [1, 2, 3, 4])).toEqual(3)
      expect(findClosest(3, [2, 3, 4, 5])).toEqual(3)
      expect(findClosest(3, [3, 4, 5, 6])).toEqual(3)
    it 'should work with 4-sized arrays when element not in list', ->
      expect(findClosest(7, [0, 2, 4, 6])).toEqual(6)
      expect(findClosest(7, [2, 4, 6, 8])).toEqual(6)
      expect(findClosest(7, [4, 6, 8, 10])).toEqual(6)
      expect(findClosest(7, [6, 8, 10, 12])).toEqual(6)
      expect(findClosest(7, [8, 10, 12, 14])).toEqual(8)
    it 'should work with float arrays when element in list', ->
      expect(findClosest(0.3, [0.3, 0.31])).toEqual(0.3)
    it 'should work with float arrays when element not in list', ->
      expect(findClosest(0.3, [0.29, 0.31])).toEqual(0.29)
  
  describe 'TimeSeries', ->
    it 'should start out empty', ->
      ts = new TimeSeries()
      expect(ts.sortedKeys).toEqual([])
    it 'should be able to store one element', ->
      ts = (new TimeSeries()).add(5, 50)
      expect((new TimeSeries()).add(5, 50).sortedKeys).toEqual([5])
      expect((new TimeSeries()).add(5, 50).add(5, 60).sortedKeys).toEqual([5])
    it 'should be able to store two elements', ->
      ts46 = (new TimeSeries()).add(4, 40).add(6, 60)
      expect(ts46.sortedKeys).toEqual([4, 6])
      ts64 = (new TimeSeries()).add(4, 40).add(6, 60)
      expect(ts64.sortedKeys).toEqual([4, 6])
    it 'should be able to store three elements', ->
      ts123 = (new TimeSeries()).add(1, 10).add(2, 20).add(3, 30)
      expect(ts123.sortedKeys).toEqual([1, 2, 3])
      ts132 = (new TimeSeries()).add(1, 10).add(3, 30).add(2, 20)
      expect(ts132.sortedKeys).toEqual([1, 2, 3])
      ts213 = (new TimeSeries()).add(2, 20).add(1, 10).add(3, 30)
      expect(ts213.sortedKeys).toEqual([1, 2, 3])
      ts231 = (new TimeSeries()).add(2, 20).add(3, 30).add(1, 10)
      expect(ts231.sortedKeys).toEqual([1, 2, 3])
      ts312 = (new TimeSeries()).add(3, 30).add(1, 10).add(2, 20)
      expect(ts312.sortedKeys).toEqual([1, 2, 3])
      ts321 = (new TimeSeries()).add(3, 30).add(2, 20).add(1, 10)
      expect(ts321.sortedKeys).toEqual([1, 2, 3])
    it 'should be able to store two elements from three adds', ->
      ts121 = (new TimeSeries()).add(1, 10).add(2, 20).add(1, 30)
      expect(ts121.sortedKeys).toEqual([1, 2])
      ts211 = (new TimeSeries()).add(2, 20).add(1, 10).add(1, 30)
      expect(ts211.sortedKeys).toEqual([1, 2])
      ts122 = (new TimeSeries()).add(1, 10).add(2, 20).add(2, 30)
      expect(ts122.sortedKeys).toEqual([1, 2])
      ts212 = (new TimeSeries()).add(2, 20).add(1, 10).add(2, 30)
      expect(ts212.sortedKeys).toEqual([1, 2])

    describe 'getClosestValueNotFartherThan', ->
      it 'should return null if TimeSeries is empty', ->
        ts = new TimeSeries()
        expect(ts.getClosestValueNotFartherThan(1)).toEqual(null)
      it 'should return value if requested exactly', ->
        ts = (new TimeSeries()).add(5, 50)
        expect(ts.getClosestValueNotFartherThan(5, 0)).toEqual(50)
      it 'should return value if requested within bounds (too low)', ->
        ts = (new TimeSeries()).add(5, 50)
        expect(ts.getClosestValueNotFartherThan(4, 1)).toEqual(50)
      it 'should return value if requested within bounds (too high)', ->
        ts = (new TimeSeries()).add(5, 50)
        expect(ts.getClosestValueNotFartherThan(6, 1)).toEqual(50)
      it 'should return null if requested outside bounds (too low)', ->
        ts = (new TimeSeries()).add(5, 50)
        expect(ts.getClosestValueNotFartherThan(3, 1)).toEqual(null)
      it 'should return null if requested outside bounds (too high)', ->
        ts = (new TimeSeries()).add(5, 50)
        expect(ts.getClosestValueNotFartherThan(7, 1)).toEqual(null)
