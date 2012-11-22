require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require './model'
require 'json'

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

      searcher.search_each(ferret_query) do |doc_id, score|
        doc = searcher[doc_id]
        song_id = doc[:song_id]
        song = Song.first(:id => song_id)
        song_name = song && song.name
        artist_name = song && song.artist && song.artist.name

        lyrics = searcher.highlight(
          ferret_query, doc_id, :lyrics, :excerpt_length => :all,
          :pre_tag => '{', :post_tag => '}').join.force_encoding('UTF-8')
        lyrics.split("\n").each_with_index do |line, line_num|
          if line.include?('{')
            @results << {
              :artist_name => artist_name,
              :song_name   => song_name,
              :song_id     => song_id,
              :line        => line,
              :line_num    => line_num,
            }
          end
        end
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
    haml :song
  end

  post '/song/:song_id' do
    song_id = params['song_id']
    link = params['youtube_video_link']

    @song = Song.first(:id => song_id)
    if link
      @song.youtube_video_id = youtube_video_link_to_video_id(link)
      @song.save rescue raise @song.errors.inspect
    end
    haml :song
  end

  get '/TestRunner' do
    haml :TestRunner
  end
end
