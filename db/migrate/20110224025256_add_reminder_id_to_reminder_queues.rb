class AddReminderIdToReminderQueues < ActiveRecord::Migration
  def self.up
    add_column :reminder_queues, :reminder_id, :integer
  end

  def self.down
    remove_column :reminder_queues, :reminder_id
  end
end
