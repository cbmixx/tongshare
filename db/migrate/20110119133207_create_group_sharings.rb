class CreateGroupSharings < ActiveRecord::Migration
  def self.up
    create_table :group_sharings do |t|
      t.integer :sharing_id
      t.integer :group_id
      t.integer :priority

      t.timestamps
    end
  end

  def self.down
    drop_table :group_sharings
  end
end
