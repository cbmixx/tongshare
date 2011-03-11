class AddRejectWarningFlag < ActiveRecord::Migration
  def self.up
    add_column :user_extras, :reject_warning_flag, :boolean
  end

  def self.down
    remove_column :user_extras, :reject_warning_flag
  end
end
