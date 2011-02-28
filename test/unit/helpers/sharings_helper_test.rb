require 'test_helper'

class SharingsHelperTest < ActionView::TestCase
  test "test for parse_sharings_raw" do
    str = "2007011329	2007011324  lywander+reg@gmail.com, 13900001111;\ninvalid\nlywander@gmail.com"
    #TODO: how to write this into fixtures??

    result = parse_sharings_raw(str)
    assert_equal(result, [
        {:type => "employee_no", :login_value => "2007011329"},
        {:type => "employee_no", :login_value => "2007011324"},
        {:type => "email", :login_value => "lywander+reg@gmail.com"},
        {:type => "mobile", :login_value => "13900001111"},
        {:type => nil, :login_value => "invalid"},
        {:type => "email", :login_value => "lywander@gmail.com"}
      ])
  end
end
