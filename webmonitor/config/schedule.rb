# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
set :output, File.expand_path("../../log/crontab.log", __FILE__)
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#

every 2.minutes do
  runner "TemperatureMonitor.check_and_notify", :environment => :development
end

every 30.minutes do
  runner "TemperatureMonitor.fetch_temperatures", :environment => :development
end
