class CreateRemovedEvents < ActiveRecord::Migration
  def self.up
    create_table :removed_events do |t|
      t.integer :event_id
      t.integer :creator_id

      t.timestamps
    end

    add_index :removed_events, :event_id
    add_index :removed_events, :creator_id
  end

  def self.down
    drop_table :removed_events
  end
end
