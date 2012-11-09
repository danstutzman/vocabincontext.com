require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'data_mapper'

DataMapper::Logger.new(STDOUT, :debug)
db_path = File.expand_path('../db.sqlite3', __FILE__)
DataMapper.setup :default, "sqlite3:#{db_path}"
class Song
  include DataMapper::Resource
  property :id, Serial, :required => true
  property :created_at, DateTime, :required => true
end
DataMapper.auto_upgrade!
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize

song = Song.new({ :created_at => DateTime.now })
song.save!

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
