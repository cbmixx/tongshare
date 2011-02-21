class CreateAcceptances < ActiveRecord::Migration
  def self.up
    create_table :acceptances do |t|
      t.integer :event_id
      t.integer :user_id
      t.integer :decision

      t.timestamps
    end
  end

  def self.down
    drop_table :acceptances
  end
end
