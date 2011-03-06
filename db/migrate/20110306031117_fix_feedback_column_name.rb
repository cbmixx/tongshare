class FixFeedbackColumnName < ActiveRecord::Migration
  def self.up
    rename_column :feedbacks, :feedback_value, :value
  end

  def self.down
  end
end
