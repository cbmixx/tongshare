class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.integer :instance_id
      t.integer :user_id
      t.string :feedback_value

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
