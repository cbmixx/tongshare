class AddIndexToLocation < ActiveRecord::Migration
  def self.up
    add_index :events, :location
    add_index :instances, :location
  end

  def self.down
    remove_index :events, :location
    remove_index :instances, :location
  end
end
