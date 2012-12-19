require 'rubygems'
require 'bundler/setup'
require 'sinatra/activerecord'

require File.join(File.dirname(__FILE__), './analyzer')
require File.join(File.dirname(__FILE__), './airbrake')

ROOT_DIR = File.expand_path('../../', __FILE__) unless defined? ROOT_DIR
FERRET_INDEX_DIR = File.join(ROOT_DIR, 'backend', 'ferret_index')

#DataMapper::Logger.new(STDERR, :debug)

class Song < ActiveRecord::Base
  validates :scraped_song_id, :presence => true
  validates :song_name,       :presence => true
  validates :artist_id,       :presence => true
  validates :artist_name,     :presence => true
  validates :song_name,       :presence => true
  validates :lyrics,          :presence => true
  has_many :alignments
end

class Alignment < ActiveRecord::Base
  validates :song_id,       :presence => true
  validates :line_num,      :presence => true
  validates :start_centis,  :presence => true
  validates :finish_centis, :presence => true
  belongs_to :song
end

class Task < ActiveRecord::Base
  validates :action, :presence => true
  validates :song_id, :presence => true
  belongs_to :song
  belongs_to :alignment
end

class BestWord < ActiveRecord::Base
  validates :word,  :presence => true
  validates :count, :presence => true
end

# ------------------

# see https://github.com/jkraemer/ferret/blob/master/ruby/TUTORIAL
require 'ferret'

def with_ferret_index(&block)
  analyzer = MyAnalyzer.new(true)

  # for some reason it helps to open and close the index first
  index = Ferret::Index::Index.new({
    :default_input_field => nil,
    :id_field => :scraped_song_id,
    :path => FERRET_INDEX_DIR,
    :analyzer => analyzer,
  })
  index.close

  index_already_existed = File.exists?(FERRET_INDEX_DIR)
  index = Ferret::Index::Index.new({
    :default_input_field => nil,
    :id_field => :scraped_song_id,
    :path => FERRET_INDEX_DIR,
    :analyzer => analyzer,
  })

  if !index_already_existed
    index.field_infos.add_field :scraped_song_id, {
      :store => :yes, :index => :untokenized, :term_vector => :no
    }
    index.field_infos.add_field :lyrics, {
      :store => :no, :index => :yes, :term_vector => :no
    }
    index.field_infos.add_field :has_alignments, {
      :store => :yes, :index => :no, :term_vector => :no
    }
    index.field_infos.add_field :metadata, {
      :store => :yes, :index => :no, :term_vector => :no
    }
  end
  
  block.call(index)

  index.close
end
