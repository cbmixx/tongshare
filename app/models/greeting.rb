class Greeting < ActiveRecord::Base
  attr_accessible :from_user_id, :to_user_id, :event_id

  validates :from_user_id, :to_user_id, :event_id, :presence => true

  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_user, :class_name => 'User'
  belongs_to :event
end
