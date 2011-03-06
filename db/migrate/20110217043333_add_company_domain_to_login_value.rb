class AddCompanyDomainToLoginValue < ActiveRecord::Migration
  class UserIdentifier < ActiveRecord::Base
    attr_accessible :login_value, :email
  end
  
  def self.up
    UserIdentifier.find_all_by_login_type("employee_no").each do |u|
      u.update_attribute :login_value, "tsinghua.edu.cn." + u.login_value
    end

    User.find(:all).each do |u|
      m = u.email.match(/(.+)@null\.tongshare\.com/)
      if !m.nil?
        u.update_attribute :email, "#{m[1]}@null.tsinghua.edu.cn"
      end
    end

  end

  def self.down
    UserIdentifier.find_all_by_login_type("employee_no").each do |u|
      m = u.login_value.match(/tsinghua\.edu\.cn\.(.+)/)
      if !m.nil?
        u.update_attribute :login_value, m[1]
      end
    end

    User.find(:all).each do |u|
      m = u.email.match(/(.+)@null\.tsinghua\.edu\.cn/)
      if !m.nil?
        u.update_attribute :email, "#{m[1]}@null.tongshare.com"
      end
    end
  end
end
