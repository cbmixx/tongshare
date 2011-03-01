class Sharing < ActiveRecord::Base
  # currently, priority is in {0, 1} for invitate and recommend respectively
  # priority is defined in user_sharing and group_sharing
  MAX_PRIORITY = 2

  attr_accessible :event_id, :shared_from, :extra_info
  
  belongs_to :event
  #belongs_to :user  #add by wander
  has_many :user_sharing, :dependent => :destroy
  has_many :group_sharing, :dependent => :destroy

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

end
