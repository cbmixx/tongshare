class AddUniqueIndexToUserIdentifier < ActiveRecord::Migration
  def self.up
    add_index :user_identifiers, [:type, :value], :unique => true
  end

  def self.down
    remove_index [:type, :value]
  end
end
