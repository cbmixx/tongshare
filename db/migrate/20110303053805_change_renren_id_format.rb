class ChangeRenrenIdFormat < ActiveRecord::Migration
  class UserExtra < ActiveRecord::Base
    attr_accessible :renren_id
  end

  def self.up
    UserExtra.find(:all, :conditions => "NOT (renren_id LIKE 'domain:%')").each do |ue|
      ue.renren_id = 'id:' + ue.renren_id
      ue.save!
    end
  end

  def self.down
    UserExtra.find(:all, :conditions => "renren_id LIKE 'id:%'").each do |ue|
      ue.renren_id = ue.renren_id[3..-1]
      ue.save!
    end
  end
end
