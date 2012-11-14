require 'data_mapper'

DataMapper::Logger.new(STDERR, :debug)
db_path = File.expand_path('../db.sqlite3', __FILE__)
DataMapper.setup :default, "sqlite3:#{db_path}"

# set all String properties to have a default length of 255
DataMapper::Property::String.length(255)

class Artist
  include DataMapper::Resource
  property :id, Serial, :required => true
  property :name, String, :required => true
  property :created_at, DateTime, :required => true
end

class Song
  include DataMapper::Resource
  property :id, Serial, :required => true
  property :artist_id, Integer, :required => true
  property :name, String, :required => true
  property :created_at, DateTime, :required => true
end

class SongLine
  include DataMapper::Resource
  property :id, Serial, :required => true
  property :artist_id, Integer, :required => true
  property :song_id, Integer, :required => true
  property :name, String, :required => true
  property :created_at, DateTime, :required => true
end

DataMapper.auto_upgrade!
DataMapper.finalize
DataMapper::Model.raise_on_save_failure = true
