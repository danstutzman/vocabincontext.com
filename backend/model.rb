require 'data_mapper'
require './analyzer'
require './airbrake'

ROOT_DIR = File.expand_path('../../', __FILE__)
FERRET_INDEX_DIR = File.join(ROOT_DIR, 'backend', 'ferret_index')

#DataMapper::Logger.new(STDERR, :debug)

if ENV['ENV'] == 'production'
  DataMapper.setup :default, {
    :adapter  => 'postgres',
    :host     => 'localhost',
    :database => 'your_app_name_production',
    :user     => 'your_app_name',
  }
else
  db_path = File.expand_path('../db.sqlite3', __FILE__)
  DataMapper.setup :default, "sqlite3:#{db_path}"
end

# set all String properties to have a default length of 255
DataMapper::Property::String.length(255)

class Song
  include DataMapper::Resource

  property :id,          Serial,   :required => true
  property :artist_id,   Integer,  :required => true
  property :artist_name, String,   :required => true
  property :song_name,   String,   :required => true
  property :lyrics,      Text,     :required => true
  property :created_at,  DateTime, :required => true

  property :youtube_video_id, String, :required => false

  has n, :alignments
end

class Alignment
  include DataMapper::Resource

  property :id,            Serial,  :required => true
  property :song_id,       Integer, :required => true
  property :line_num,      Integer, :required => true
  property :start_centis,  Integer, :required => true
  property :finish_centis, Integer, :required => true

  belongs_to :song
end

class BestWord
  include DataMapper::Resource
  property :id, Serial, :required => true
  property :word, String, :required => true
  property :count, Integer, :required => true
  property :created_at, DateTime, :required => true
end

class Task
  include DataMapper::Resource

  # properties that exist when task created
  property :id, Serial, :required => true
  property :action, String, :required => true
  property :song_id, Integer, :required => true, :index => true
  property :alignment_id, Integer, :required => false, :index => true
  property :created_at, DateTime, :required => true

  # properties that get filled out as task executes
  property :command_line, String
  property :started_at, DateTime
  property :completed_at, DateTime
  property :stdout, Text
  property :stderr, Text
  property :exit_status, Integer

  belongs_to :song
  belongs_to :alignment
end

DataMapper.auto_upgrade!
DataMapper.finalize

DataMapper::Model.raise_on_save_failure = true

# ------------------

# see https://github.com/jkraemer/ferret/blob/master/ruby/TUTORIAL
require 'ferret'

def with_ferret_index(&block)
  analyzer = MyAnalyzer.new(true)

  # for some reason it helps to open and close the index first
  index = Ferret::Index::Index.new({
    :default_input_field => nil,
    :id_field => :song_id,
    :path => FERRET_INDEX_DIR,
    :analyzer => analyzer,
  })
  index.close

  index_already_existed = File.exists?(FERRET_INDEX_DIR)
  index = Ferret::Index::Index.new({
    :default_input_field => nil,
    :id_field => :song_id,
    :path => FERRET_INDEX_DIR,
    :analyzer => analyzer,
  })

  if !index_already_existed
    index.field_infos.add_field :song_id, {
      :store => :yes, :index => :untokenized, :term_vector => :no
    }
    index.field_infos.add_field :lyrics, {
      :store => :no, :index => :yes, :term_vector => :no
    }
    index.field_infos.add_field :has_start_times, {
      :store => :yes, :index => :no, :term_vector => :no
    }
    index.field_infos.add_field :metadata, {
      :store => :yes, :index => :no, :term_vector => :no
    }
  end
  
  block.call(index)

  index.close
end
