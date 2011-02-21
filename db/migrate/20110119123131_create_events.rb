class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.datetime :begin
      t.datetime :end
      t.string :location
      t.text :extra_info
      t.integer :creator_id

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
