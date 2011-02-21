class CreateSharings < ActiveRecord::Migration
  def self.up
    create_table :sharings do |t|
      t.integer :event_id
      t.integer :shared_from
      t.text :extra_info

      t.timestamps
    end
  end

  def self.down
    drop_table :sharings
  end
end
