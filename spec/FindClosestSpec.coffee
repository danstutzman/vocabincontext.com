findClosest = require('../app/FindClosest').findClosest

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
