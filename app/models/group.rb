class Group < ActiveRecord::Base
  # the length here is UTF8 char length
  MAX_NAME_LENGTH = 32
  MAX_EXTRA_INFO_LENGTH = 4096
  MAX_IDENTIFIER_LENGTH = 16
  
  belongs_to :creator, :class_name => "User"
  has_many :membership, :dependent => :destroy
  has_many :group_sharing, :dependent => :destroy

  validates :name, :identifier, :creator_id, :presence => true
  validates :identifier, :uniqueness => true
  validates_length_of :name, :maximum => MAX_NAME_LENGTH
  validates_length_of :extra_info, :maximum => MAX_EXTRA_INFO_LENGTH
  validates_length_of :identifier, :maximum => MAX_IDENTIFIER_LENGTH

  #return nil if the user is not a member of this group
  def member_power(user)
    return nil if user.nil?
    result = membership.find :first, :user => user
    return nil if result.nil?
    return result.power
  end
end
