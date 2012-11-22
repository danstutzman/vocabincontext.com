require 'rubygems' if RUBY_VERSION < '1.9'
require './model'
require 'open3'

TIMEOUT = 10 * 60 # kill process after X minutes of waiting for stdout/stderr

task = Task.first({
  :action => 'download_mp3',
  :started_at => nil,
  :order => [:id]
})
if task
  p task
  task.started_at = DateTime.now
  task.save rescue raise task.errors.inspect

  if task.action == 'download_mp3'
    video_id = task.song.youtube_video_id
    if video_id.match(/^[a-zA-Z0-9_-]{11}$/)
      command_line = "cd #{ROOT_DIR} && backend/youtube_to_mp3.sh #{video_id}"
      p command_line

      all_stdout, all_stderr, exit_status = '', '', nil
      Open3.popen3(command_line) do |stdin, stdout, stderr, wait_thr|
        timeout = false
        while wait_thr.status
          read_ready, write_ready = IO.select([stdout, stderr], [], [], TIMEOUT)

          if read_ready == nil
            timeout = true
            break
          end

          if read_ready.include?(stdout)
            begin
              new_stdout = stdout.readpartial(4096)
              puts "STDOUT #{new_stdout}"
              all_stdout += new_stdout
            rescue EOFError
            end
          end

          if read_ready.include?(stderr)
            begin
              new_stderr = stderr.readpartial(4096)
              puts "STDERR #{new_stderr}"
              all_stderr += new_stderr
            rescue EOFError
            end
          end
        end

        if timeout
          puts 'Timeout!'
          all_stderr += "\n(Killing because of timeout)\n"
          Process.kill "KILL", wait_thr.pid
        else
          new_stdout = stdout.read
          puts "STDOUT #{new_stdout}"
          all_stdout += new_stdout
  
          new_stderr = stderr.read
          puts "STDERR #{new_stderr}"
          all_stderr += new_stderr
        end

        exit_status = wait_thr.value.exitstatus
      end
      task.command_line = command_line
      task.stdout = all_stdout
      task.stderr = all_stderr
      task.exit_status = exit_status
    else
      task.stderr = "youtube_video_id fails regex check: #{video_id}"
      task.exit_status = -1
    end

    if task.exit_status == 0
      task.destroy
      p "Task completed successfully"
    else
      task.completed_at = DateTime.now
      task.save rescue raise task.errors.inspect
      p task
    end
  end
end
