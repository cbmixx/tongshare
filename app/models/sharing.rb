class Sharing < ActiveRecord::Base
  # currently, priority is in {0, 1} for invitate and recommend respectively
  # priority is defined in user_sharing and group_sharing
  MAX_PRIORITY = 2

  attr_accessible :event_id, :shared_from, :extra_info
  
  belongs_to :event
  belongs_to :user, :foreign_key => "shared_from"  #add by wander
  
  has_many :user_sharings, :dependent => :destroy
  has_many :group_sharings, :dependent => :destroy
  #sth. to clearify: both has_many :user_sharings and has_many :user_sharing work, but the former will define a method user.user_sharings while the latter user.user_sharing
  #Conventionally, it should be user_sharings. But in User there are too much has_many will wrong convention! so just ignore it...

  validates :event_id, :shared_from, :presence => true

  validate do |sharing|
    sharing.user_sharings.each do |us|
      next if us.valid?
      us.errors.each do |attr, err|
        errors.add attr, err
      end
    end
  end

  def add_user_sharing (user_id, priority)
    self.user_sharings.build(
      :user_id => user_id,
      :priority => priority
    )
  end

  def add_group_sharing(group_id)
    self.group_sharings.build(
      :group_id => group_id,
      :priority => 1 # only recommendation is allowed for public group sharing
    )
  end

end
