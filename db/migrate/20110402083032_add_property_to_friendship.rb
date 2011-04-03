class AddPropertyToFriendship < ActiveRecord::Migration
  def self.up
    add_column :friendships, :property, :string
  end

  def self.down
    remove_column :friendships, :property, :string
  end
end
