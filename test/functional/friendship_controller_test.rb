require 'test_helper'

class FriendshipControllerTest < ActionController::TestCase
  test "should get add_or_remove" do
    get :add_or_remove
    assert_response :success
  end

end
