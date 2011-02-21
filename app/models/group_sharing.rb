# Currently, column priority is in {0, 1} where 0 is invitation and 1 is
# recommendation. Later, more priority levels may be added. 
class GroupSharing < ActiveRecord::Base
  PRIORITY_INVITE = 0
  PRIORITY_RECOMMENDATION = 1

  belongs_to :sharing
  belongs_to :group
  
  validates :group_id, :sharing_id, :priority, :presence => true
  validates_numericality_of :priority, :only_integer => true, :less_than => Sharing::MAX_PRIORITY
end
