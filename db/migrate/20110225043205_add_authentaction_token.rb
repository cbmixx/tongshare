class AddAuthentactionToken < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.token_authenticatable
    end
    add_index :users, :authentication_token, :unique => true
  end

  def self.down
    remove_index :users, :authentication_token
    #FIXME anything here?
    remove_column :users, :authentication_token #add by Wander
    #TODO: is it right?
  end
end
