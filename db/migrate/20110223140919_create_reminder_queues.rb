class CreateReminderQueues < ActiveRecord::Migration
  def self.up
    create_table :reminder_queues do |t|
      t.datetime :time
      t.integer :method_type
      t.integer :instance_id

      t.timestamps
    end
  end

  def self.down
    drop_table :reminder_queues
  end
end
