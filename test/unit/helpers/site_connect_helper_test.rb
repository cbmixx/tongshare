require 'test_helper'

class SiteConnectHelperTest < ActionView::TestCase
  include SiteConnectHelper
  
  test "test renren parser" do
    puts 1
    r = parse_renren_url("http://www.renren.com/profile.do?id=356208904")
    puts "result: " + r.to_yaml
    assert_equal("356208904", r)

    puts 2
    r = parse_renren_url("http://www.renren.com/tongshare")
    assert_equal("domain:tongshare", r)

    puts 3
    r = parse_renren_url("www.renren.com/profile.do?id=356208904")
    assert_equal("356208904", r)

    puts 4
    r = parse_renren_url("www.renren.com/tongshare")
    assert_equal("domain:tongshare", r)

    puts 5
    r = parse_renren_url("356208904")
    assert_equal("356208904", r)

    puts 6
    r = parse_renren_url("tongshare")
    assert_equal("domain:tongshare", r)

    puts 7
    r = parse_renren_url("home")
    assert_nil(r)

    puts 8
    r = parse_renren_url("http://www.renren.com/home")
    assert_nil(r)

    puts 9
    r = parse_renren_url("www.renren.com/profile")
    assert_nil(r)
  end

  test "test renren generator" do
    r = generate_renren_url("356208904")
    assert_equal("http://www.renren.com/profile.do?id=356208904", r)

    r = generate_renren_url("domain:tongshare")
    assert_equal("http://www.renren.com/tongshare", r)

    r = generate_renren_url("356208904", true)
    assert_equal("http://3g.renren.com/profile.do?id=356208904", r)

    r = generate_renren_url("domain:tongshare", true)
    assert_equal("http://www.renren.com/tongshare", r)
  end
      
end
