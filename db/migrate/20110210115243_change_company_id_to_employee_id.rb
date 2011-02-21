#change company_id to employee_no (no menas No.)
#because "company_id" is ambiguous, it may be the id of a model named "Company".
class ChangeCompanyIdToEmployeeId < ActiveRecord::Migration
  def self.up
    execute "UPDATE `user_identifiers` SET type = 'employee_no' WHERE type = 'company_id'"
  end

  def self.down
    execute "UPDATE `user_identifiers` SET type = 'company_no' WHERE type = 'employee_id'"
  end
end
