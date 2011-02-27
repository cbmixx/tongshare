class AddPublicToUserExtra < ActiveRecord::Migration
  def self.up
    add_column :user_extras, :public, :boolean, :default => false
  end

  def self.down
    remove_column :user_extras, :public
  end
end
