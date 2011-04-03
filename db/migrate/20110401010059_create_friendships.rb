class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :from_user
      t.integer :to_user

      t.timestamps
    end

    add_index :friendships, :from_user
    add_index :friendships, :to_user
  end

  def self.down
    drop_table :friendships
  end
end
