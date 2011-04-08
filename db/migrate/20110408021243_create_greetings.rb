class CreateGreetings < ActiveRecord::Migration
  def self.up
    create_table :greetings do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.integer :event_id

      t.timestamps
    end
  end

  def self.down
    drop_table :greetings
  end
end
