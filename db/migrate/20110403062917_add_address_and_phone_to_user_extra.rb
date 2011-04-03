class AddAddressAndPhoneToUserExtra < ActiveRecord::Migration
  def self.up
    add_column :user_extras, :address, :string
    add_column :user_extras, :phone, :string
  end

  def self.down
    remove_column :user_extras, :address, :string
    remove_column :user_extras, :phone, :string
  end
end
