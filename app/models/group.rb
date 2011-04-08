class Group < ActiveRecord::Base
  # the length here is UTF8 char length
  MAX_NAME_LENGTH = 32
  MAX_EXTRA_INFO_LENGTH = 4096
  MAX_IDENTIFIER_LENGTH = 16

  # will there be more privacies?
  PRIVACY_PUBLIC = 0
  PRIVACY_PRIVATE = 1

  attr_accessible :name, :extra_info, :identifier, :creator_id, :privacy

  belongs_to :creator, :class_name => "User"
  has_many :membership, :dependent => :destroy
  has_many :group_sharing, :dependent => :destroy

  validates :name, :creator_id, :presence => true
  #validates :identifier, :uniqueness => true
  validates_length_of :name, :maximum => MAX_NAME_LENGTH
  validates_length_of :extra_info, :maximum => MAX_EXTRA_INFO_LENGTH
  #validates_length_of :identifier, :maximum => MAX_IDENTIFIER_LENGTH
  validate do |group|
      query = Group.where(:creator_id => group.creator_id, :name => group.name)
      errors.add :name, :already_exists if query.exists? and query.first.id != group.id
  end

  #return nil if the user is not a member of this group
  def member_power(user)
    return nil if user.nil?
    # TODO is this right?
    return Membership::POWER_SUPER_MANAGER if user.id == self.creator_id
    result = membership.find_by_user_id user.id
    return nil if result.nil?
    return result.power
  end

  def set_member_power(user, power)
    return false if user.nil?
    return false if user.id == self.creator_id
    result = membership.find_by_user_id user.id
    return false if result.nil?
    result.power = power
    result.save
  end

  def members
    self.membership.map{|ms| ms.user}
  end

  #TODO need test
  def has_member?(user)
    return (self.membership.find_by_user_id(user.id) != nil)
  end

  def add_member (login_type, login_value, power = Membership::POWER_MEMBER)
    user = UserIdentifier.find_user_by(login_type, login_value)
    return nil if user.nil?
    ms = user.membership.new(
      :group_id => self.id,
      :power => power
    )
    ms.save
  end

  def add_member (user, power = Membership::POWER_MEMBER)
    return nil if user.nil?
    ms = user.membership.new(
      :group_id => self.id,
      :power => power
    )
    ms.save
  end

  # members is an array constructed with hashes of {:user_id or (:login_type and :login_value) and :power}
  #
  def set_members (members)
    self.membership.delete_all
    self.membership(true)
    members.each do |member|
      user_id = member[:user_id] if User.where(:id => member[:user_id]).exists?
      if user_id.nil?
        user = UserIdentifier.find_user_by(member[:login_type], member[:login_value])
        user_id = user.id if !user.nil?
      end
      power = member[:power]
      next if user_id.nil? or power.nil? or user_id == self.creator_id
      self.membership.build(
        :user_id => user_id,
        :power => power
      )
    end
    self.save
  end

  def remove_member (user)
    return nil if user.nil?
    ms = membership.find :first, :user => user
    return nil if ms.nil?
    ms.destroy
  end

end