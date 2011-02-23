class ChangeTokenLengthAgain < ActiveRecord::Migration
  def self.up
    change_column :consumer_tokens, :token, :string, :limit => 128
  end

  def self.down
    change_column :consumer_tokens, :token, :string, :limit => 12
  end
end
