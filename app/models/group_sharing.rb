# Group sharing now is all about recommendation
# If it's invitation, the sharing will create user_sharing
# for each user in the group.
# The priority column is no removed but it's useless and depracated.
class GroupSharing < ActiveRecord::Base
  PRIORITY_INVITE = 0 # depracated
  PRIORITY_RECOMMENDATION = 1 # depracated

  belongs_to :sharing
  belongs_to :group
  
  validates :group_id, :priority, :presence => true
  #:sharing_id
  validates_numericality_of :priority, :only_integer => true, :less_than => Sharing::MAX_PRIORITY
end
