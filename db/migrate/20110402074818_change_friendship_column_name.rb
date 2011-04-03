class ChangeFriendshipColumnName < ActiveRecord::Migration
  def self.up
    rename_column :friendships, :from_user, :from_user_id
    rename_column :friendships, :to_user, :to_user_id
  end

  def self.down
    rename_column :friendships, :from_user_id, :from_user
    rename_column :friendships, :to_user_id, :to_user
  end
end
