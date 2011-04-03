class Friendship < ActiveRecord::Base
  BIDIRECTIONAL = 'bidirectional'
  UNIDIRECTIONAL = 'unidirectional'

  attr_accessible :from_user_id, :to_user_id, :property

  belongs_to :from_user, :class_name => 'User'
  belongs_to :to_user, :class_name => 'User'

  after_save :set_property
  after_destroy :remove_property

  def set_property
    f = Friendship.find_by_from_user_id_and_to_user_id(self.to_user_id, self.from_user_id)
    if (f && f.property != BIDIRECTIONAL)
      f.property = BIDIRECTIONAL
      f.save!
    end
    if (f && self.property != BIDIRECTIONAL)
      self.property = BIDIRECTIONAL
      self.save!
    end
    if (!f && self.property != UNIDIRECTIONAL)
      self.property = UNIDIRECTIONAL
      self.save!
    end
  end

  def remove_property
    f = Friendship.find_by_from_user_id_and_to_user_id(self.to_user_id, self.from_user_id)
    if (f && f.property == BIDIRECTIONAL)
      f.property = UNIDIRECTIONAL
      f.save!
    end
  end
end
