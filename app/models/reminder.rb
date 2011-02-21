class Reminder < ActiveRecord::Base
  belongs_to :event, :class_name => "Event" 
end
