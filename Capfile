gemfile = File.expand_path(File.join(__FILE__, '..', 'Gemfile'))
if File.exist?(gemfile) && ENV['BUNDLE_GEMFILE'].nil?
  puts "Respawning with 'bundle exec'"
  exec("bundle", "exec", "cap", *ARGV)
end

load 'deploy' if respond_to?(:namespace) # cap2 differentiator

env = ENV['RUBBER_ENV'] ||= (ENV['RAILS_ENV'] || 'production')
root = File.dirname(__FILE__)

# this tries first as a rails plugin then as a gem
$:.unshift "#{root}/vendor/plugins/rubber/lib/"
require 'rubber'

Rubber::initialize(root, env)
require 'rubber/capistrano'

Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

task :build_js do
  run "cd #{current_path} && make lint"
  run "cd #{current_path} && make backend/public/js/main-compiled.js"
end
after "deploy:update_code", "build_js"

namespace :ferret_index do
  desc 'Create ferret_index dir and sets proper upload permissions'
  task :create_dir, :except => { :no_release => true } do
    dir = File.join(shared_path, 'ferret_index')
    chown_to = "#{rubber_env.app_user}:#{rubber_env.app_user}"
    run "#{try_sudo} mkdir -p #{dir} &&
      #{try_sudo} chmod g+w #{dir} &&
      #{try_sudo} chown -R #{chown_to} #{dir}"
  end
  after "deploy:setup", "ferret_index:create_dir"

  desc <<-EOD
    [internal] Creates the symlink to uploads shared folder
    for the most recently deployed version.
  EOD
  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/backend/ferret_index"
    run "ln -nfs #{shared_path}/ferret_index #{release_path}/backend/ferret_index"
  end
  after "deploy:finalize_update", "ferret_index:symlink"
end
