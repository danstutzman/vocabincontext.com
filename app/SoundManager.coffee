# don't init soundManager until beginDelayedInit() is called
window.SM2_DEFER = true

define [
    '/lib/soundmanagerv297a-20120513/script/soundmanager2.js',
    ], (ignored) ->
  sm = new SoundManager()
  sm.url = '/lib/soundmanagerv297a-20120513/swf'
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
