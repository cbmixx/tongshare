class AddCreatorIdToInstances < ActiveRecord::Migration
  def self.up
    add_column :instances, :creator_id, :integer
  end

  def self.down
    remove_column :instances, :creator_id
  end
end
