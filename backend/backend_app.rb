require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require './model'
require 'json'
require './ferret_search'
require 'youtube_it'

class BackendApp < Sinatra::Base
  if ENV['ENV'] == 'production'
    use Airbrake::Rack
    enable :raise_errors
  end

  configure do
    set :haml, {:format => :html5, :escape_html => true, :ugly => true}
    set :static, true
    set :public_folder, File.join(ROOT_DIR, 'backend', 'public')

    if ENV['ENV'] == 'production'
      set :static_cache_control, [:public, :max_age => 300]
    else
      set :static_cache_control, [:public, :no_cache]
    end
  end

  not_found do
    '404 Your page cannot be found'
  end

  def serve_search
    query = params['query']
    offset = params['offset'].to_i
    @excerpts = FerretSearch.search_for(query, offset) if query
    @title = 'Search for vocab in context'
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
    serve_search
  end

  post '/' do
    serve_search
  end

  helpers do
    def format_centis(centis)
      if centis
        mins = centis / 6000
        secs = (centis - (mins * 6000)) / 100.0
        sprintf('%d:%05.2f', mins, secs)
      end
    end
  end

  get '/song/:song_id' do
    song_id = params['song_id']
    @song = find_song_in_db_or_ferret(song_id) or halt 404
    @lyrics_lines = @song.lyrics.split("\n")

    @start_finish_centis_by_line_num = [[nil, nil]] * @lyrics_lines.size
    @song.alignments.each do |alignment|
      @start_finish_centis_by_line_num[alignment.line_num] =
        [alignment.start_centis, alignment.finish_centis]
    end
    @title = @song.song_name

    haml :song
  end

  def param_value_to_centis(value)
    return nil if value.nil? || value == ''
    match = value.match(/^(([0-9]+):)?([0-9]+(\.[0-9]+)?)$/)
    raise "Invalid time value: #{value}" if match.nil?
    mins, secs = match[2].to_i, match[3].to_f
    (mins * 6000) + (secs * 100).round
  end

  post '/song/:song_id' do
    song_id = params['song_id']
    video_id = params['youtube_video_id']
    link = params['youtube_video_link']

    @song = find_song_in_db_or_ferret(song_id) or halt 404
    if link && link != ''
      video_id = youtube_video_link_to_video_id(link)
    end
    if video_id && video_id != ''
      @song.youtube_video_id = video_id
      @song.save rescue raise @song.errors.inspect

      unless Task.first({ :action => 'download_mp4', :song_id => song_id })
        task = Task.new({
          :action => 'download_mp4',
          :song_id => song_id,
          :created_at => DateTime.now,
        })
        task.save rescue raise task.errors.inspect
      end
    end
    if params['remove_youtube_video']
      @song.youtube_video_id = nil
      @song.save rescue raise @song.errors.inspect
    end

    alignments = []
    num_lines = @song.lyrics.split("\n").size
    Alignment.all(:song_id => song_id).destroy!
    [num_lines, 500].min.times do |line_num| # limit to 500 to avoid DOS attack
      alignment = Alignment.new({
        :song_id => song_id,
        :line_num => line_num,
        :start_centis => param_value_to_centis(params['s'][line_num]),
        :finish_centis => param_value_to_centis(params['f'][line_num]),
      })
      if alignment.start_centis && alignment.finish_centis
        alignment.save rescue raise alignment.errors.inspect
        alignments.push alignment
      end
    end

    existing_tasks = Task.all({ :action => 'split_mp4', :song_id => song_id })
    alignments.each do |alignment|
      existing = existing_tasks.find do |task|
        task.alignment_id == alignment.id
      end
      unless existing
        task = Task.new({
          :action => 'split_mp4',
          :song_id => song_id,
          :alignment_id => alignment.id,
          :created_at => DateTime.now,
        })
        task.save rescue raise task.errors.inspect
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

  get '/youtube-search/:query' do |query|
    client = YouTubeIt::Client.new
    videos = client.videos_by(:query => query, :per_page => 6)
    if videos.feed_id
      @videos = videos.videos

      if params['no_layout']
        haml :youtube_search, :layout => false
      else
        haml :youtube_search
      end
    else
      'Error: unable to contact youtube.com'
    end
  end
end
