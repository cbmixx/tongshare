class AddUniqueToAcceptances < ActiveRecord::Migration
  def self.up
    add_index :acceptances, [:user_id, :event_id], :uniqueness => true, :name => 'acceptances_user_event_index'
  end

  def self.down
    remove_index :acceptances, :name => 'acceptances_user_event_index'
  end
end
