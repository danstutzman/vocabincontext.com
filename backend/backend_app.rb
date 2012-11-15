require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require './model'

QUERY_REGEX = /^\w+$/

class BackendApp < Sinatra::Base
  configure do
    set :haml, {:format => :html5, :escape_html => true}
  end

  def get_term_counts
    reader = Ferret::Index::IndexReader.new('index')
    @term_counts = []
    reader.terms(:lyrics).each do |term, doc_freq|
      if doc_freq > 100
        @term_counts << [term, doc_freq]
      end
    end
    @term_counts = @term_counts.sort_by { |term_count| -term_count[1] }
    @term_counts = @term_counts[0..100]
  end

  def serve_search
    query = params['query']

    if query
      @results = []
      searcher = Ferret::Search::Searcher.new('index')
      analyzer = MyAnalyzer.new
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

        lyrics = searcher.highlight(
          ferret_query, doc_id, :lyrics, :excerpt_length => :all,
          :pre_tag => '{', :post_tag => '}')
        lyrics.join.split("\n").each do |line|
          if line.include?('{')
            @results << "#{song_id} #{line}"
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
