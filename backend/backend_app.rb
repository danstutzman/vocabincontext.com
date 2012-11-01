require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'

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
    @results = `grep -ri "#{query}" ../song_lyrics`
    haml :search
  end
end
