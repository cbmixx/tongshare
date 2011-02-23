class ChangeIndexLengthAgain < ActiveRecord::Migration
  def self.up
    remove_index "consumer_tokens", :column => :token
    add_index "consumer_tokens", ["token"], :name => "index_consumer_tokens_on_token", :length => {"token"=>"128"}, :unique => true
  end

  def self.down
    remove_index "consumer_tokens", :column => :token
    add_index "consumer_tokens", ["token"], :name => "index_consumer_tokens_on_token", :length => {"token"=>"76"}, :unique => true
  end
end
