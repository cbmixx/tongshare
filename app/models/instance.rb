class Instance < ActiveRecord::Base
  attr_accessible :name, :begin, :end, :location, :extra_info, :event_id, :index, :override, :creator_id
  attr_accessible :event
  belongs_to :event
  #validates :event_id, :creator_id, :presence => true
end
