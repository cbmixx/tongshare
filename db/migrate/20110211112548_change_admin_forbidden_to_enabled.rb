#a change to enhance security
class ChangeAdminForbiddenToEnabled < ActiveRecord::Migration
  class AdminExtra < ActiveRecord::Base
  end

  def self.up
    #execute "UPDATE admin_extras SET is_forbidden = NOT is_forbidden"
    AdminExtra.update_all("is_forbidden = NOT is_forbidden")
    rename_column :admin_extras, :is_forbidden, :admin_enabled
  end

  def self.down #untested
    AdminExtra.update_all("admin_enabled = NOT admin_enabled")
    rename_column :admin_extras, :admin_enabled, :is_forbidden
    #execute "UPDATE admin_extras SET is_forbidden = NOT is_forbidden"
  end
end
