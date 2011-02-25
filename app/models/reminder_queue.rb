class ReminderQueue < ActiveRecord::Base
  attr_accessible :method_type, :time
  belongs_to :instance
  belongs_to :reminder
end
