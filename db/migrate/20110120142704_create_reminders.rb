class CreateReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.integer :method_type
      t.integer :value
      t.integer :time_type

      t.timestamps
    end
  end

  def self.down
    drop_table :reminders
  end
end
