# encoding: UTF-8
#this will destroy old uid = 1 and create a new one
class AddUid1AndConfirmedToUser < ActiveRecord::Migration
  def self.up
    add_column :user_identifiers, :confirmed, :boolean, :default => false

    begin
      old = User.find(1)
      old.destroy unless old.nil?
    rescue
      
    end
    
    u = User.new({:id=>1, :email => "admin@tongshare.com", :password => "adminadmin"})
    u.build_user_extra({:name => "同享日程系统管理员"})
    u.user_identifier.build({:login_type => "email", :login_value => "admin@tongshare.com"})

    u.skip_confirmation!
    u.save!

  end

  def self.down
    remove_column :user_identifiers, :confirmed

    begin
      u = User.find(1)
      u.destroy unless u.nil?
    rescue
      
    end
  end
end
