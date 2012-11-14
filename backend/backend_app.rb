require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require './model'

QUERY_REGEX = /^\w+$/

class BackendApp < Sinatra::Base
  get '/' do
    redirect '/search'
  end

  get '/search' do
    haml :search
  end

  post '/search' do
    query = params['query']
    raise "Query doesn't pass white list" if !query.match(QUERY_REGEX)
    @results = []
    with_ferret_index do |index|
      index.search_each("lyrics:#{query}") do |id, score|
        doc = index[id]
        @results << "song_id='#{doc[:song_id]}' lyrics='#{doc[:lyrics]}'"
      end
    end
    haml :search
  end
end
