#a change to enhance security
class ChangeAdminForbiddenToEnabled < ActiveRecord::Migration
  def self.up
    execute "UPDATE admin_extras SET is_forbidden = NOT is_forbidden"
    rename_column :admin_extras, :is_forbidden, :admin_enabled
  end

  def self.down
    rename_column :admin_extras, :admin_enabled, :is_forbidden
    execute "UPDATE admin_extras SET is_forbidden = NOT is_forbidden"
  end
end
