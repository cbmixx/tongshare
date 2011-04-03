class AddIndexToGroupsAndMemberships < ActiveRecord::Migration
  def self.up
    add_index :groups, :identifier
    add_index :groups, :creator_id
    add_index :memberships, :group_id
    add_index :memberships, :user_id
  end

  def self.down
    remove_index :groups, :identifier
    remove_index :groups, :creator_id
    remove_index :memberships, :group_id
    remove_index :memberships, :user_id
  end
end
