class CreateInstances < ActiveRecord::Migration
  def self.up
    create_table :instances do |t|
      t.string :name
      t.datetime :begin
      t.datetime :end
      t.string :location
      t.text :extra_info
      t.integer :event_id
      t.integer :index
      t.boolean :override

      t.timestamps
    end
  end

  def self.down
    drop_table :instances
  end
end
