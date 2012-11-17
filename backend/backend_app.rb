require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require './model'
require 'json'

class BackendApp < Sinatra::Base
  configure do
    set :haml, {:format => :html5, :escape_html => true}
  end

  def get_term_counts
    @term_counts = JSON.load(File.read('./best_words.json'))
    @term_counts = @term_counts.map { |hash|
      [hash['word'], hash['count']]
    }
  end

  def serve_search
    query = params['query']

    if query
      @results = []
      searcher = Ferret::Search::Searcher.new('index')
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
        lyrics.split("\n").each do |line|
          if line.include?('{')
            @results << {
              :artist_name => artist_name,
              :song_name   => song_name,
              :song_id     => song_id,
              :line        => line,
            }
          end
        end
      end
    end

    get_term_counts
    haml :search
  end

  get '/' do
    redirect '/search'
  end

  get '/search' do
    serve_search
  end

  post '/search' do
    serve_search
  end
end
