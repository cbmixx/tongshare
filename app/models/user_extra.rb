class UserExtra < ActiveRecord::Base
  attr_accessible :user_id, :name, :mobile, :public
  belongs_to :user
  #TODO validate
end
