require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require './model'
require 'json'
require './ferret_search'

class BackendApp < Sinatra::Base
  if ENV['ENV'] == 'production'
    use Airbrake::Rack
    enable :raise_errors
  end

  configure do
    set :haml, {:format => :html5, :escape_html => true}
    set :static, true
    set :public_folder, File.join(ROOT_DIR, 'backend', 'public')
    set :static_cache_control, [:public, :no_cache]
  end

  not_found do
    '404 Your page cannot be found'
  end

  def get_term_counts
    @term_counts = BestWord.all.map { |best_word|
      [best_word.word, best_word.count]
    }
  end

  def serve_search
    query = params['query']
    offset = params['offset'].to_i

    if query
      excerpts = FerretSearch.search_for(query, offset)
      @labeled_excerpts, @unlabeled_excerpts = excerpts.partition { |excerpt|
        excerpt[:start_time] && excerpt[:end_time]
      }
    end

    get_term_counts

    haml :search
  end

  def youtube_video_link_to_video_id(link)
    if match = link.match(/v=(.{11})/)
      match[1]
    else
      raise "Couldn't find 11-character video ID in YouTube link: #{link}"
    end
  end

  def find_song_in_db_or_ferret(song_id)
    song = Song.first(:id => song_id)
    if song.nil?
      doc = FerretSearch.find_song_by_id(song_id)
      return nil if doc.nil?

      lyrics = doc[:lyrics].force_encoding('UTF-8')
      metadata = JSON.load(doc[:metadata] || '{}')
      artist_id = doc[:artist_id]

      song = Song.new({
        :id => song_id,
        :song_name => metadata['song_name'],
        :artist_id => artist_id,
        :artist_name => metadata['artist_name'],
        :lyrics => lyrics,
        :created_at => DateTime.now,
      })
    end
    song
  end

  get '/' do
    redirect '/search'
  end

  get '/index' do
    haml :index
  end

  get '/segmenter' do
    haml :segmenter
  end

  get '/search' do
    serve_search
  end

  post '/search' do
    serve_search
  end

  get '/song/:song_id' do
    song_id = params['song_id']
    @song = find_song_in_db_or_ferret(song_id) or halt 404
    @lyrics_lines = @song.lyrics.split("\n")
    @start_times = JSON.load(@song.start_times_json || '[]')
    haml :song
  end

  post '/song/:song_id' do
    song_id = params['song_id']
    link = params['youtube_video_link']

    @song = find_song_in_db_or_ferret(song_id) or halt 404
    if link && link != ''
      @song.youtube_video_id = youtube_video_link_to_video_id(link)
      @song.save rescue raise @song.errors.inspect

      unless Task.first({ :action => 'download_mp3', :song_id => song_id })
        task = Task.new({
          :action => 'download_mp3',
          :song_id => song_id,
          :created_at => DateTime.now,
        })
        task.save rescue raise task.errors.inspect
      end
    end

    start_times = []
    num_lines = @song.lyrics.split("\n").size
    [num_lines, 500].min.times do |line_num| # limit to 500 to avoid DOS attack
      start_time = params["start_time_line_#{line_num}"]
      start_time = start_time.match(/^[0-9]+$/) ? start_time.to_i : ''
      start_times.push start_time
    end
    while start_times.last == ''
      start_times.pop
    end
    @song.start_times_json = JSON.dump(start_times)
    @song.save rescue raise @song.errors.inspect

    if (@song.start_times_json || '[]') != '[]'
      existing_tasks = Task.all({ :action => 'split_mp3', :song_id => song_id })
      start_times.each_with_index do |start_time, line_num|
        end_time = start_times[line_num + 1]
        if Integer === start_time && Integer === end_time
          existing = existing_tasks.find do |task|
            task.start_time == start_time &&
            task.end_time == end_time
          end
          unless existing
            task = Task.new({
              :action => 'split_mp3',
              :song_id => song_id,
              :start_time => start_time,
              :end_time => end_time,
              :created_at => DateTime.now,
            })
            task.save rescue raise task.errors.inspect
          end
        end
      end
    end

    unless Task.first({ :action => 'update_index', :song_id => song_id })
      task = Task.new({
        :action => 'update_index',
        :song_id => song_id,
        :created_at => DateTime.now,
      })
      task.save rescue raise task.errors.inspect
    end

    redirect "/song/#{song_id}"
  end

  get '/TestRunner' do
    haml :TestRunner
  end

  get '/split_mp3s/:filename' do |filename|
    send_file "#{ROOT_DIR}/backend/youtube_downloads/#{filename}"
  end
end
