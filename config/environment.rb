# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Tongshare::Application.initialize!

ActiveRecord::Base.connection.instance_variable_set :@logger, Logger.new(STDOUT)  #log SQL statements

CalendarDateSelect::FORMATS[:chinese] = {
# Here's the code to pass to Date#strftime
  :date => "%Y年%m月%d日",
  :time => " %I:%M %p",  # notice the space before time.  If you want date and time to be seperated with a space, put the leading space here.

  :javascript_include => "format_chinese"
}
CalendarDateSelect.format = :iso_date