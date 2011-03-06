class AddIndexToAcceptancesEventsInstancesSharingsUsersUserextrasUseridentifiersUsersharings < ActiveRecord::Migration
  def self.up
    add_index :acceptances, :event_id
    add_index :acceptances, :user_id

    add_index :events, :begin
    add_index :events, :end
    add_index :events, :creator_id
    add_index :events, :updated_at

    add_index :instances, :begin
    add_index :instances, :end
    add_index :instances, :event_id
    add_index :instances, :creator_id

    add_index :sharings, :event_id
    add_index :sharings, :shared_from

    add_index :user_extras, :user_id
    add_index :user_extras, :name

    add_index :user_identifiers, :user_id
    add_index :user_identifiers, :confirmed

    add_index :user_sharings, :sharing_id
    add_index :user_sharings, :user_id
    add_index :user_sharings, :priority
  end

  def self.down
    remove_index :acceptances, :event_id
    remove_index :acceptances, :user_id

    remove_index :events, :begin
    remove_index :events, :end
    remove_index :events, :creator_id
    remove_index :events, :updated_at

    remove_index :instances, :begin
    remove_index :instances, :end
    remove_index :instances, :event_id
    remove_index :instances, :creator_id

    remove_index :sharings, :event_id
    remove_index :sharings, :shared_from

    remove_index :user_extras, :user_id
    remove_index :user_extras, :name

    remove_index :user_identifiers, :user_id
    remove_index :user_identifiers, :confirmed

    remove_index :user_sharings, :sharing_id
    remove_index :user_sharings, :user_id
    remove_index :user_sharings, :priority
  end
end
