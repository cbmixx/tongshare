class AddIndexToFeedback < ActiveRecord::Migration
  def self.up
    add_index :feedbacks, :user_id
    add_index :feedbacks, :instance_id
  end

  def self.down
    remove_index :feedbacks, :user_id
    remove_index :feedbacks, :instance_id
  end
end
