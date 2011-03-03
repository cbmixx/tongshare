class ChangeRenrenUrlToRenrenId < ActiveRecord::Migration
  def self.up
    rename_column :user_extras, :renren_url, :renren_id
  end

  def self.down
    rename_column :user_extras, :renren_id, :renren_url
  end
end
