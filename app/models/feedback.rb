class Feedback < ActiveRecord::Base
  WARNING = :warning

  attr_accessible :user_id, :instance_id, :value

  belongs_to :user, :instance
end
