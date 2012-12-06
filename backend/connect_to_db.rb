require 'yaml'
require 'erb'
require 'sinatra/activerecord'

unless defined? ROOT_DIR
  ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
end
env = ((ENV['ENV'] || '') != '') ? ENV['ENV'] : 'development'
database_yml =
  YAML::load(ERB.new(File.read("#{ROOT_DIR}/config/database.yml")).result)
ActiveRecord::Base.establish_connection database_yml[env]
