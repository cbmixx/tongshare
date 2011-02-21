#unfortunately, 'value' and 'type' are both RESERVED by rails!!!
class ChangeTypeValueOfUserIdentifier < ActiveRecord::Migration
  def self.up
    rename_column :user_identifiers, :type, :login_type
    rename_column :user_identifiers, :value, :login_value
  end

  def self.down
    rename_column :user_identifiers, :login_type, :type
    rename_column :user_identifiers, :login_value, :value
  end
end
