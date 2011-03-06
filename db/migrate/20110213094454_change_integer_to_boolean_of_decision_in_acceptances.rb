class ChangeIntegerToBooleanOfDecisionInAcceptances < ActiveRecord::Migration
  def self.up
    change_column :acceptances, :decision, :boolean
  end

  def self.down
    change_column :acceptances, :decision, :integer
  end
end
