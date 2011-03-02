class AddRenrenUrlToUserExtra < ActiveRecord::Migration
  def self.up
    add_column :user_extras, :renren_url, :string
  end

  def self.down
    remove_column :user_extras, :renren_url
  end
end
