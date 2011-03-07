# encoding: UTF-8
#this will destroy old uid = 1 and create a new one
class AddUid1AndConfirmedToUser < ActiveRecord::Migration

  class User < ActiveRecord::Base
    devise :database_authenticatable,
         :token_authenticatable, #for mobile auto-login
         :recoverable, :rememberable, :trackable,
         :registerable,
         :validatable,
         :confirmable #email verify
    attr_accessible :id, :email, :password
    has_many :user_identifier, :dependent => :destroy
    has_one :user_extra, :dependent => :destroy
  end

  class UserIdentifier < ActiveRecord::Base
    belongs_to :user
    attr_accessible :login_type, :login_value
  end

  class UserExtra < ActiveRecord::Base
    belongs_to :user
    attr_accessible :name, :user_id
  end

  def self.up
    add_column :user_identifiers, :confirmed, :boolean, :default => false
    UserIdentifier.reset_column_information

    begin
      old = User.find(1)
      old.destroy unless old.nil?
    rescue
      
    end
    
    u = User.new({:id=>1, :email => "admin@tongshare.com", :password => "adminadmin"})
    u.skip_confirmation!
    u.save!

    ue = UserExtra.new({:user_id=>u.id, :name=>"同享日程系统管理员"})
    ue.save!

    ui = UserIdentifier.new({:user_id=>u.id, :login_type => "email", :login_value => "admin@tongshare.com"})
    ui.save!

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
