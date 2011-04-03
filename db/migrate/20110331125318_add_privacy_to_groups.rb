class AddPrivacyToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :privacy, :integer
  end

  def self.down
    remove_column :groups, :privacy
  end
end