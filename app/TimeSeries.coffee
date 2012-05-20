exports.findClosest = (needle, haystack) ->
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
