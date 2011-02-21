set :application, "tongshare"
set :repository,  "https://tongshare.googlecode.com/svn/trunk/tongshare/"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :user, "deployer"
set :runner, "deployer"

set :scm, :subversion
set :scm_user, "paullzn"
set :scm_password, "Zv9Kw9sF2kJ9"

server "lives3.net", :app, :web, :db, :primary => true

default_run_options[:pty] = true

set :rails_env, :production
set :unicorn_binary, "/usr/bin/unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle install && rake db:migrate RAILS_ENV=production && #{try_sudo} #{unicorn_binary} -c#{unicorn_config} -E #{rails_env} -D"
  end
  
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    sleep 5
    start
  end
end

