require 'rubygems' if RUBY_VERSION < '1.9'
require 'rubygems'
require 'bundler/setup'
require 'open3'
require 'json'
require 'socket'
require 'daemons'
require 'logger'

TIMEOUT = 10 * 60 # kill process after X minutes of waiting for stdout/stderr
STDOUT.sync = true

def centis_to_msh(centis) # msh = minutes.seconds.hundredths
  minutes = centis / 6000
  seconds = (centis / 100) % 60
  hundredths = centis % 100
  sprintf('%02d.%02d.%02d', minutes, seconds, hundredths)
end

def execute_command(command_line, task, log)
  log.info "command line: #{command_line}"

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
      log.info 'Timeout!'
      all_stderr += "\n(Killing because of timeout)\n"
      Process.kill "KILL", wait_thr.pid
    else
      new_stdout = stdout.read
      log.info "STDOUT #{new_stdout}"
      all_stdout += new_stdout

      new_stderr = stderr.read
      log.info "STDERR #{new_stderr}"
      all_stderr += new_stderr
    end

    exit_status = wait_thr.value.exitstatus
  end
  task.command_line = command_line
  task.stdout = (task.stdout || '') + all_stdout
  task.stderr = (task.stderr || '') + all_stderr
  task.exit_status = exit_status
end

def run_any_existing_tasks(log)
  log.info "Looking for tasks..."
  task = Task.first({
    :action => %w[download_mp4 split_mp4 update_index],
    :started_at => nil,
    :order => [:id]
  })
  if task
    log.info "Found #{task.inspect}"
  else
    log.info "Found none."
    return false
  end

  task.started_at = DateTime.now
  task.save rescue raise task.errors.inspect

  if task.action == 'download_mp4'
    video_id = task.song.youtube_video_id
    if video_id.match(/^[a-zA-Z0-9_-]{11}$/)
      command_line = "cd #{ROOT_DIR} && backend/youtube_to_mp4.sh #{video_id}"
      execute_command command_line, task, log
    else
      task.stderr = "youtube_video_id fails regex check: #{video_id}"
      task.exit_status = -1
    end
  elsif task.action == 'split_mp4'
    song = task.song
    alignment = task.alignment
    if song && alignment
      video_id = song.youtube_video_id
      start_seconds = sprintf('%.2f',
        [(alignment.start_centis - 100) / 100.0, 0.0].max)
      duration_seconds = sprintf('%.2f',
        (alignment.finish_centis - alignment.start_centis + 200) / 100.0)
      output_filename = sprintf("%s.%05d.%05d.mp3",
        video_id, alignment.start_centis.to_s, alignment.finish_centis.to_s)
      command_line = "backend/excerpt_clip.sh "
      command_line += "#{video_id} "
      command_line += "#{start_seconds} "
      command_line += "#{duration_seconds} "
      command_line += "#{output_filename} "
      command_line = "cd #{ROOT_DIR} && #{command_line}"
      execute_command command_line, task, log

      alignment.location = 'fs'
      alignment.save rescue raise alignment.errors.inspect
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
    log.info "Task completed successfully"
  else
    task.completed_at = DateTime.now
    task.save rescue raise task.errors.inspect
  end
  true
end

BACKEND_DIR = File.expand_path('../', __FILE__)
Daemons.run_proc('task_runner', {
    :app_name => 'task_runner',
    :dir_mode => :normal,
    :dir => "#{BACKEND_DIR}/../log",
    :backtrace => true,
    :log_output => true,
    }) do
  require File.join(BACKEND_DIR, 'model')
  require File.join(BACKEND_DIR, 'ferret_search')
  File.open "#{BACKEND_DIR}/../log/task_runner.log", 'a' do |log_out|
    log = Logger.new(log_out)
    log.level = Logger::INFO

    #$stdout.reopen log_out, 'a'
    #$stderr.reopen log_out, 'a'
    log_out.sync = true
    #$stdout.sync = true
    #$stderr.sync = true
    Socket.unix_server_loop("/tmp/wake_up_vocabincontext_task_runner") do
        |sock, client_addrinfo|
      begin
        while true
          run_any_existing_tasks(log) or break
        end
      ensure
        sock.close
      end
    end
  end
end
