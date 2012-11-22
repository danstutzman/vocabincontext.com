require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require './model'
require 'json'

MAX_NUM_EXCERPTS_TO_RETURN = 10

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

  def get_term_counts
    @term_counts = BestWord.all.map { |best_word|
      [best_word.word, best_word.count]
    }
  end

  def serve_search
    query = params['query']

    if query
      @results = []
      searcher = Ferret::Search::Searcher.new(FERRET_INDEX_DIR)
      analyzer = MyAnalyzer.new(true)
      if query.split(' ').size > 1
        ferret_query = Ferret::Search::PhraseQuery.new(:lyrics)
        token_stream = analyzer.token_stream(:lyrics, query)
        while token = token_stream.next
          ferret_query << token.text
        end
      else
        term = analyzer.token_stream(:lyrics, query).next.text
        ferret_query = Ferret::Search::TermQuery.new(:lyrics, term)
      end

      num_excerpts_returned = 0
      searcher.search_each(ferret_query, options) do |doc_id, score|
        doc = searcher[doc_id]
        song_id = doc[:song_id]
        song = Song.first(:id => song_id)
        song_name = song && song.name
        artist_name = song && song.artist && song.artist.name
        start_times = (song && song.start_times_json) ?
          JSON.load(song.start_times_json) : []

        lyrics = searcher.highlight(
          ferret_query, doc_id, :lyrics, :excerpt_length => :all,
          :pre_tag => '{', :post_tag => '}').join.force_encoding('UTF-8')
        lyrics.split("\n").each_with_index do |line, line_num|
          if line.include?('{')
            start_time = start_times[line_num]
            end_time = start_times[line_num + 1]
            @results << {
              :youtube_video_id => song.youtube_video_id,
              :artist_name      => artist_name,
              :song_name        => song_name,
              :song_id          => song_id,
              :line             => line,
              :line_num         => line_num,
              :start_time       => start_time,
              :end_time         => end_time,
            }
            num_excerpts_returned += 1
            break if num_excerpts_returned >= MAX_NUM_EXCERPTS_TO_RETURN
          end
        end
        break if num_excerpts_returned >= MAX_NUM_EXCERPTS_TO_RETURN
      end
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
    @song = Song.first(:id => song_id)
    @lyrics_lines = @song.lyrics.split("\n")
    @start_times = JSON.load(@song.start_times_json || '[]')
    haml :song
  end

  post '/song/:song_id' do
    song_id = params['song_id']
    link = params['youtube_video_link']

    @song = Song.first(:id => song_id)
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

    redirect "/song/#{song_id}"
  end

  get '/TestRunner' do
    haml :TestRunner
  end

  get '/split_mp3s/:filename' do |filename|
    send_file "#{ROOT_DIR}/backend/youtube_downloads/#{filename}"
  end
end
