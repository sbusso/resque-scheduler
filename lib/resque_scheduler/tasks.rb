require 'resque/tasks'
# will give you the resque tasks

namespace :resque do
  task :setup

  desc "Start Resque Scheduler"
  task :scheduler => :scheduler_setup do
    require 'resque'
    require 'resque_scheduler'

    if ENV['BACKGROUND']
      unless Process.respond_to?('daemon')
        abort "env var BACKGROUND is set, which requires ruby >= 1.9"
      end
      Process.daemon(true)
    end
    pidfile = ENV['PIDFILE'] || 'tmp/pids/resque-scheduler.pid'
    File.open(pidfile, 'w') { |f| f << Process.pid.to_s }

    Resque::Scheduler.dynamic = true if ENV['DYNAMIC_SCHEDULE']
    Resque::Scheduler.verbose = true if ENV['VERBOSE']
    Resque::Scheduler.run
  end

  task :scheduler_setup do
    if ENV['INITIALIZER_PATH']
      load ENV['INITIALIZER_PATH'].to_s.strip
    else
      Rake::Task['resque:setup'].invoke
    end
  end

end
