class CreateAdminExtras < ActiveRecord::Migration
  def self.up
    create_table :admin_extras do |t|
      t.integer :user_id
      t.boolean :is_forbidden

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_extras
  end
end
