class AddShareTokenToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :share_token, :string
  end

  def self.down
    remove_column :events, :share_token
  end
end
