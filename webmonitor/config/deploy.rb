require "bundler/capistrano"
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano" # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2' # Or whatever env you want it to run in.

set :application, "webmonitor"
set :repository,  "git@github.com:m3nd3s/webmonitor.git"

set :scm, :git
set :branch, "master"
set :scm_verbose, true
set :use_sudo, false
set :ssh_options, { :forward_agent => true }

set :user, "root"
set :deploy_to, "/var/www/websupervisor"

role :web, "192.168.3.29"                          # Your HTTP server, Apache/etc
role :app, "192.168.3.29"                          # This may be the same as your `Web` server
role :db,  "192.168.3.29", :primary => true # This is where Rails migrations will run

after 'deploy', 'deploy:rvmrc', 'deploy:database', 'deploy:migrate', 'deploy:seed', 'deploy:restart'
namespace :deploy do
  task :restart, :roles => :app do
    run "cd #{current_path} && touch tmp/restart.txt"
  end

  task :seed, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production bundle exec rake db:seed"
  end

  task :database, :roles => :app do
    run "cp #{deploy_to}/shared/database.yml #{current_path}/config/"
  end

  task :rvmrc, :roles => :app do
    run "rm -f #{current_path}/.rvmrc"
  end

end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
