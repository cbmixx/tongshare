class AddEventidToReminders < ActiveRecord::Migration
  def self.up
    add_column :reminders, :event_id, :integer
  end

  def self.down
    remove_column :reminders, :event_id
  end
end
