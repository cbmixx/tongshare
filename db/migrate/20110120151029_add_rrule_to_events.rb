class AddRruleToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :rrule, :string
  end

  def self.down
    remove_column :events, :rrule
  end
end
