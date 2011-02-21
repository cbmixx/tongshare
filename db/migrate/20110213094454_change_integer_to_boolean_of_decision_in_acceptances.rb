class ChangeIntegerToBooleanOfDecisionInAcceptances < ActiveRecord::Migration
  def self.up
    change_column :acceptances, :decision, :boolean
  end

  def self.down
  end
end
