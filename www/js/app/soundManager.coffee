define ['soundmanager2'], (ignored) ->
  sm = new SoundManager()
  sm.url = 'swf'
  sm.debugMode = false
  sm.useFlashBlock = false
  sm.flashVersion = 9
  sm.flash9Options.useEQData = true
  sm.flash9Options.usePeakData = true
  #sm.useHighPerformance = true
  #sm.useFastPolling = true
  window.soundManager = sm # Flash expects window.soundManager
  sm.beginDelayedInit()
  return sm
