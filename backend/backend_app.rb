require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require File.join(File.dirname(__FILE__), './model')
require 'json'
require File.join(File.dirname(__FILE__), './ferret_search')
require 'youtube_it'
require 'sass'
require 'coffee-filter'
require 'compass'
require 'socket'
require 'sinatra/activerecord'

class BackendApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension

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
      set :sass, { :style => :compressed }
      # unicorn will do the connecting
    else
      set :static_cache_control, [:public, :no_cache]
      set :sass, { :style => :compact }
      load File.join(File.dirname(__FILE__), './connect_to_db.rb')
    end

    Sass.load_paths << Compass::Frameworks['compass'].stylesheets_directory
  end

  not_found do
    '404 Your page cannot be found'
  end

  def youtube_video_link_to_video_id(link)
    if match = link.match(/v=(.{11})/)
      match[1]
    else
      raise "Couldn't find 11-character video ID in YouTube link: #{link}"
    end
  end

  def find_song_in_db_or_ferret(scraped_song_id)
    song = Song.find_by_scraped_song_id(scraped_song_id.to_i)
    if song.nil?
      doc = FerretSearch.find_song_by_scraped_song_id(scraped_song_id)
      return nil if doc.nil?

      lyrics = doc[:lyrics].force_encoding('UTF-8')
      metadata = JSON.load(doc[:metadata] || '{}')
      artist_id = doc[:artist_id]

      song = Song.new({
        :scraped_song_id => scraped_song_id,
        :song_name => metadata['song_name'],
        :artist_id => artist_id,
        :artist_name => metadata['artist_name'],
        :lyrics => lyrics,
      })
    end
    song
  end

  get '/' do
    @title = 'Search for vocab in context'
    haml :search
  end

  post '/' do
    query = params['query']
    redirect "/query/#{query}"
  end

  get '/query/:query' do |query|
    offset = params['offset'].to_i
    @excerpts = FerretSearch.search_for(query, offset)
    @title = query
    haml :query
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

  get '/song/:scraped_song_id' do
    scraped_song_id = params['scraped_song_id']
    @song = find_song_in_db_or_ferret(scraped_song_id) or halt 404
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

  post '/song/:scraped_song_id' do
    scraped_song_id = params['scraped_song_id']
    video_id = params['youtube_video_id']
    link = params['youtube_video_link']

    @song = find_song_in_db_or_ferret(scraped_song_id) or halt 404
    if link && link != ''
      video_id = youtube_video_link_to_video_id(link)
    end
    if video_id && video_id != ''
      @song.youtube_video_id = video_id
      @song.save!

      unless Task.exists?({ :action => 'download_mp4', :song_id => @song.id })
        task = Task.new({
          :action => 'download_mp4',
          :song_id => @song.id,
        })
        task.save!
      end
    end

    if params['remove_youtube_video']
      @song.youtube_video_id = nil
      @song.alignments.destroy_all
      @song.save!
    else
      num_lines = @song.lyrics.split("\n").size
      [num_lines, 500].min.times do |line_num| # limit to 500
        start_centis = param_value_to_centis(params['s'][line_num])
        finish_centis = param_value_to_centis(params['f'][line_num])
        if start_centis && finish_centis
          existing_alignment = Alignment.where({
            :song_id => @song.id,
            :line_num => line_num
          }).first
          if existing_alignment
            if existing_alignment.start_centis != start_centis ||
               existing_alignment.finish_centis != finish_centis
              existing_alignment.start_centis = start_centis
              existing_alignment.finish_centis = finish_centis
              existing_alignment.save!
  
              task = Task.new({
                :action => 'split_mp4',
                :song_id => @song.id,
                :alignment_id => existing_alignment.id,
              })
              task.save!
            end
          else
            alignment = Alignment.new({
              :song_id => @song.id,
              :line_num => line_num,
              :start_centis => start_centis,
              :finish_centis => finish_centis,
            })
            alignment.save!
  
            task = Task.new({
              :action => 'split_mp4',
              :song_id => @song.id,
              :alignment_id => alignment.id,
            })
            task.save!
          end
        end # if this alignment has start and finish_centis
      end # loop through lines
    end # if removing youtube video or not

    begin
      socket = UNIXSocket.new("/tmp/wake_up_vocabincontext_task_runner")
      socket.write "wake_up\n"
      socket.close
    rescue Errno::ENOENT => e
      p e
    end

    FerretSearch.update_index_from_db @song

    redirect "/song/#{scraped_song_id}"
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

  get '/css/application.css' do
    sass 'sass/application'.intern
  end

  get '/test/test.mp3' do
    send_file "#{ROOT_DIR}/backend/views/test/test.mp3"
  end
  get '/test/:template' do |template|
    haml "test/#{template}".intern
  end
end
