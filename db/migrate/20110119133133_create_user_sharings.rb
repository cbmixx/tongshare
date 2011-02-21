class CreateUserSharings < ActiveRecord::Migration
  def self.up
    create_table :user_sharings do |t|
      t.integer :sharing_id
      t.integer :user_id
      t.integer :priority

      t.timestamps
    end
  end

  def self.down
    drop_table :user_sharings
  end
end
