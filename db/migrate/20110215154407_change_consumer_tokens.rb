class ChangeConsumerTokens < ActiveRecord::Migration
  def self.up
    change_column :consumer_tokens, :token, :string, :limit => 512
  end

  def self.down
    change_column :consumer_tokens, :token, :string, :limit => 1024
  end
end
