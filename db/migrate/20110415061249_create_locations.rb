class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name

      t.timestamps
    end

    add_index :locations, :name, :unique => true

    for event in Event.all
      Location.create!(:name => event.location) if Location.find_by_name(event.location).nil?
    end
  end

  def self.down
    drop_table :locations
  end
end
