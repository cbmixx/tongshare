require 'test_helper'

class InstanceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Simple Create" do
    pp users
    pp users.class
    pp users.methods
    pp users(:one)

    instance = Instance.new(:name => "SimpleInstaceToTestCreatorId", :creator_id => 1)
    instance.save
    assert !Instance.last.creator_id.nil?
  end
end
