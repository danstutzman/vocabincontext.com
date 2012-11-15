require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'haml'
require './model'

QUERY_REGEX = /^\w+$/

class BackendApp < Sinatra::Base
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
    raise "Query doesn't pass white list" if query && !query.match(QUERY_REGEX)

    if query
      @results = []
      with_ferret_index do |index|
        index.search_each("lyrics:#{query}") do |id, score|
          doc = index[id]
          @results << "song_id='#{doc[:song_id]}' lyrics='#{doc[:lyrics]}'"
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
