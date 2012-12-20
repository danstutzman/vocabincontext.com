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
  run "cd #{release_path} && make lint"
  run "cd #{release_path} && make backend/public/js/main-compiled.js"
end
after "deploy:update_code", "build_js"

namespace :ferret_indexes do
  desc 'Create ferret_indexes dir and sets proper upload permissions'
  task :create_dir, :except => { :no_release => true } do
    dir = File.join(shared_path, 'ferret_indexes')
    chown_to = "#{rubber_env.app_user}:#{rubber_env.app_user}"
    run "#{try_sudo} mkdir -p #{dir} &&
      #{try_sudo} chmod g+w #{dir} &&
      #{try_sudo} chown -R #{chown_to} #{dir}"
  end
  after "deploy:setup", "ferret_indexes:create_dir"

  desc <<-EOD
    [internal] Creates the symlink to uploads shared folder
    for the most recently deployed version.
  EOD
  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/backend/ferret_indexes"
    run "ln -nfs #{shared_path}/ferret_indexes #{release_path}/backend/ferret_indexes"
  end
  after "deploy:finalize_update", "ferret_indexes:symlink"

  desc 'Overwrite existing remote ferret_indexes with copy of local indexes'
  task :overwrite, :except => { :no_release => true } do
    run "#{try_sudo} rm -rf #{shared_path}/ferret_indexes_uploaded #{shared_path}/ferret_indexes_old"
    upload 'backend/ferret_indexes', "#{shared_path}/ferret_indexes_uploaded",
      :via => :sftp, :recursive => true
    chown_to = "#{rubber_env.app_user}:#{rubber_env.app_user}"
    run "#{try_sudo} chown -R #{chown_to} #{shared_path}/ferret_indexes_uploaded"
    run "#{try_sudo} mv #{shared_path}/ferret_indexes #{shared_path}/ferret_indexes_old && #{try_sudo} mv #{shared_path}/ferret_indexes_uploaded #{shared_path}/ferret_indexes"
  end
end

namespace :youtube_downloads do
  desc 'Create youtube_downloads dir and sets proper upload permissions'
  task :create_dir, :except => { :no_release => true } do
    dir = File.join(shared_path, 'youtube_downloads')
    chown_to = "#{rubber_env.app_user}:#{rubber_env.app_user}"
    run "#{try_sudo} mkdir -p #{dir} &&
      #{try_sudo} chmod g+w #{dir} &&
      #{try_sudo} chown -R #{chown_to} #{dir}"
  end
  after "deploy:setup", "youtube_downloads:create_dir"

  desc <<-EOD
    [internal] Creates the symlink to uploads shared folder
    for the most recently deployed version.
  EOD
  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/backend/youtube_downloads"
    run "ln -nfs #{shared_path}/youtube_downloads #{release_path}/backend/youtube_downloads"
  end
  after "deploy:finalize_update", "youtube_downloads:symlink"
end
