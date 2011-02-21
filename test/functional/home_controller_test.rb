require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    sign_in users(:one)
    get :index
    assert_response 302 # should be redirected
  end

end
