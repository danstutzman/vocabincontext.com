# Deploying Sinatra apps to Amazon EC2 using rubber (normally used for Rails deployment to EC2)
#
# Rakefile needed by rubber for non-rails apps
#
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
 
env = ENV['RUBBER_ENV'] ||= (ENV['RAILS_ENV'] || 'development')
root = File.dirname(__FILE__)
 
require 'rubber'
 
Rubber::initialize(root, env)
 
require 'rubber/tasks/rubber'
