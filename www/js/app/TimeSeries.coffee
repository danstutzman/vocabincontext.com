define ->

  findClosest = (needle, haystack) ->
    low = 0
    high = haystack.length - 1
    mid = Math.floor((low + high) / 2)
   
    while low <= high
      mid = Math.floor((low + high) / 2)
      elementBelow = haystack[mid]
      elementAbove = haystack[mid + 1]
      if needle < elementBelow
        high = mid - 1
      else if needle > elementAbove
        low = mid + 1
      else if needle == elementBelow
        return elementBelow
      else if needle == elementAbove
        return elementAbove
      else
        return elementBelow
  
    return haystack[mid]
  
  class TimeSeries
    constructor: ->
      @sortedKeys = []
      @keyToValue = []
  
    add: (key, value) ->
      low = 0
      high = @sortedKeys.length - 1
      mid = Math.floor((low + high) / 2)
     
      while low <= high
        mid = Math.floor((low + high) / 2)
        elementBelow = @sortedKeys[mid]
        elementAbove = @sortedKeys[mid + 1]
        if key < elementBelow
          high = mid - 1
        else if key > elementAbove
          low = mid + 1
        else if key == elementBelow
          @keyToValue[elementBelow] = value
          return this
        else if key == elementAbove
          @keyToValue[elementAbove] = value
          return this
        else
          @sortedKeys.splice mid + 1, 0, key
          @keyToValue[key] = value
          return this
    
      if key < @sortedKeys[mid]
        @sortedKeys.splice mid, 0, key
      else
        @sortedKeys.splice mid + 1, 0, key
      @keyToValue[key] = value
      return this

    getClosestKey: (key) ->
      findClosest(key, @sortedKeys)

    getClosestValue: (key) ->
      closestKey = findClosest(key, @sortedKeys)
      @keyToValue[closestKey]
  
  return {
    'findClosest': findClosest
    'TimeSeries': TimeSeries
  }
