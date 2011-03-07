class Feedback < ActiveRecord::Base
  WARNING = "warning"
  DISABLE_WARNING = "disable warning"

  attr_accessible :user_id, :instance_id, :value

  belongs_to :user
  belongs_to :instance
end
