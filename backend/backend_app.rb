require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'

class BackendApp < Sinatra::Base
  get '/' do
    'Minimal Sinatra Hello World!'
  end
end
