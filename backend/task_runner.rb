require 'rubygems' if RUBY_VERSION < '1.9'
require './model'
require 'open3'
require 'json'
require './ferret_search'

TIMEOUT = 10 * 60 # kill process after X minutes of waiting for stdout/stderr

def centis_to_msh(centis) # msh = minutes.seconds.hundredths
  minutes = centis / 6000
  seconds = (centis / 100) % 60
  hundredths = centis % 100
  sprintf('%02d.%02d.%02d', minutes, seconds, hundredths)
end

def execute_command(command_line, task)
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
end

mp3splt =
  if File.exists?('/usr/bin/mp3splt')
    '/usr/bin/mp3splt'
  elsif File.exists?('/usr/local/bin/mp3splt')
    '/usr/local/bin/mp3splt'
  else
    raise "Don't know where to find mp3splt"
  end

task = Task.first({
  :action => %w[download_mp3 split_mp3 update_index],
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
      execute_command command_line, task
    else
      task.stderr = "youtube_video_id fails regex check: #{video_id}"
      task.exit_status = -1
    end
  elsif task.action == 'split_mp3'
    song = task.song
    alignment = task.alignment
    if song && alignment
      video_id = song.youtube_video_id
      start_centis = alignment.start_centis
      finish_centis = alignment.finish_centis
      command_line = "#{mp3splt} -d #{ROOT_DIR}/backend/youtube_downloads"
      command_line += " -o #{video_id}.#{start_centis}.#{finish_centis}"
      command_line += " #{ROOT_DIR}/backend/youtube_downloads/#{video_id}.mp3"
      command_line += " #{centis_to_msh(start_centis)}"
      command_line += " #{centis_to_msh(finish_centis)}"
      execute_command command_line, task
    else
      task.stderr = 'missing song or alignment for song_id or alignment_id'
      task.exit_status = -1
    end
  elsif task.action == 'update_index'
    FerretSearch.update_index_from_db(task.song_id)
    task.exit_status = 0 # simulate running command-line utility successfully
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
