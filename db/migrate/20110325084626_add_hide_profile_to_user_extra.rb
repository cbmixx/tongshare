class AddHideProfileToUserExtra < ActiveRecord::Migration
  def self.up
    add_column :user_extras, :hide_profile, :boolean
  end

  def self.down
    remove_column :user_extras, :hide_profile
  end
end
