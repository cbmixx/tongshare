set :application, "tongshare_branch"
set :repository,  "https://tongshare.googlecode.com/svn/branches/branch_reminder/tongshare/"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :user, "tongshare"
set :runner, "tongshare"

set :scm, :subversion
set :scm_user, "paullzn"
set :scm_password, "Zv9Kw9sF2kJ9"

server "t.tongshare.com", :app, :web, :db, :primary => true

default_run_options[:pty] = true

set :rails_env, :production
set :unicorn_binary, "/usr/bin/unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c#{unicorn_config} -E #{rails_env} -D"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end

  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
end

#optional task to reconfigure databases (copied from book Agile)
after "deploy:update_code", :link_and_bundle_install
desc "install the necessary prerequisites"
task :link_and_bundle_install, :roles => :app do
#  run "cd #{release_path} && bundle install"
  run "ln -s /var/www/tongshare/shared/environments/production.rb #{release_path}/config/environments/production.rb && ln -s /var/www/tongshare/shared/public/javascripts/translations.js #{release_path}/public/javascripts/translations.js && ln -s /var/www/tongshare/shared/data #{release_path}/data && cd #{release_path} && bundle install"
end