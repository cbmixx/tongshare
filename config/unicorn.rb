worker_processes 2
working_directory "/var/www/tongshare/current/"

# This loads the application in the master process before forking
# # worker processes
# # Read more about it here:
# # http://unicorn.bogomips.org/Unicorn/Configurator.html
preload_app false # LYQ to LZN: why this is false?
#
timeout 1200
#
# # This is where we specify the socket.
listen "127.0.0.1:3000", :backlog => 64
#
pid "/var/www/tongshare/current/tmp/pids/unicorn.pid"
#
# # Set the path of the log files inside the log folder of the testapp
stderr_path "/var/www/tongshare/current/log/unicorn.stderr.log"
stdout_path "/var/www/tongshare/current/log/unicorn.stdout.log"
#
before_fork do |server, worker|
  # # This option works in together with preload_app true setting
  # # What is does is prevent the master process from holding
  # # the database connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
  old_pid = '/var/www/tongshare/current/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  #       # Here we are establishing the connection after forking worker
  #       # processes
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
