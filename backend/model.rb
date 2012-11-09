require 'data_mapper'

DataMapper::Logger.new(STDOUT, :debug)
db_path = File.expand_path('../db.sqlite3', __FILE__)
DataMapper.setup :default, "sqlite3:#{db_path}"
class Song
  include DataMapper::Resource
  property :id, Serial, :required => true
  property :name, String, :required => true
  property :created_at, DateTime, :required => true
end
DataMapper.auto_upgrade!
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize
