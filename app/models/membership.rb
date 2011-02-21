# model changed by Wander
# Naturally, the bigger POWER is, the bigger power a user has. NOT THE OPPOSITE!!
# Normal member has power 0. Positive value means management permissions, while negative value means limited member.
# A group manager will be able to assign power to group members, but never assign power bigger than himself.
class Membership < ActiveRecord::Base
  POWER_LOWER_BOUND = -1
  POWER_MEMBER = 0
  POWER_MANAGER = 1
  POWER_SUPER_MANAGER = 2  #able to invite group (IG)
  POWER_UPPER_BOUND = 3  
  
  belongs_to :group
  belongs_to :user
  
  validates :power, :group_id, :user_id, :presence => true
  validates_numericality_of :power, :only_integer => true, :less_than => POWER_UPPER_BOUND, :greater_than => POWER_LOWER_BOUND
end
