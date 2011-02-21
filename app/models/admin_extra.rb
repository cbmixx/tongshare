class AdminExtra < ActiveRecord::Base
  belongs_to :user
  attr_accessible :admin_enabled
end
