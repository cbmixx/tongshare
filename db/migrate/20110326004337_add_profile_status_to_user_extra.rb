class AddProfileStatusToUserExtra < ActiveRecord::Migration
  def self.up
    add_column :user_extras, :profile_status, :string
  end

  def self.down
    remove_column :user_extras, :profile_status
  end
end
