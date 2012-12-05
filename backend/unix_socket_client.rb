require 'socket'
begin
  socket = UNIXSocket.new("/tmp/wake_up_vocabincontext_task_runner")
  socket.write 'wakeup'
  socket.close
rescue Errno::ENOENT => e
  p e
end
