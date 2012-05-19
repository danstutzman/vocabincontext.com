soundManager.url = 'soundmanagerv297a-20120513/swf';
soundManager.debugMode = false;
soundManager.useFlashBlock = false;
soundManager.flashVersion = 9;
soundManager.flash9Options.useEQData = true;
soundManager.flash9Options.usePeakData = true;
soundManager.useHighPerformance = true;
soundManager.useFastPolling = true;

$(document).ready(function() {
  $("#slider").slider({
    slide: function(event, ui) {
      var millis = ui.value / 100.0 * globals.theSound.duration;
      globals.theSound.setPosition(millis);
    }
  });
});

lastActualX = 0;
function whilePlaying() {
  var canvas = document.getElementById('canvas');
  var canvasDiv = document.getElementById('canvas-div');
  var context = canvas.getContext('2d');
  var halfWidth = canvas.width / 2;
  millisecondsToPixels = 0.05;
  var actualX =
    Math.floor(this.position * millisecondsToPixels);
  context.fillStyle = 'rgb(0,0,0)';

  // draw fake waveform
  if (this.peakData) {
    height = (this.peakData.left + this.peakData.right) / 2 * 18;
    context.clearRect(lastActualX, 260,
      actualX - lastActualX, canvas.height - 260);
    context.fillStyle = 'rgb(0,0,0)';
    context.fillRect(lastActualX, 280 - height,
      actualX - lastActualX, height * 2);
  }
  lastActualX = actualX;
}

soundManager.onready(function() {
  globals = {
    theSound: soundManager.createSound({
      id: 'theSound',
      url: '/Eb-chord.mp3',
      useEQData: true,
      usePeakData: true,
      whileplaying: whilePlaying
    })
  };
});
