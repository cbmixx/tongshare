class AddPhotoAndDepartmentToUserExtra < ActiveRecord::Migration
  def self.up
    add_column :user_extras, :photo_url, :string
    add_column :user_extras, :department, :string
  end

  def self.down
    remove_column :user_extras, :photo_url
    remove_column :user_extras, :department
  end
end
