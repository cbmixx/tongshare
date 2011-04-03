require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  include GroupsHelper
  fixtures :users
  setup do
    Group.delete_all
  end
  test "basic test" do
    user = User.find 1
    member = User.find 2
    ret = add_group("TestGroup", 1, Group::PRIVACY_PRIVATE, "extra~")
    assert ret
    group = query_group_via_name_and_creator_id("TestGroup", 1)
    assert !group.nil?
    #test for uniqueness of creator and name
    add_group(1, "TestGroup")
    assert_equal 1, Group.where(:creator_id => 1).count, 'uniqueness test of creator and name failed'

    assert_equal Membership::POWER_SUPER_MANAGER, group.member_power(user), 'test for power of creator failed'
    UserIdentifier.new(:login_type => UserIdentifier::TYPE_EMAIL, :login_value => "foo@bar.com", :user_id => 999).save
    group.set_members [
      {:user_id => 2, :power => Membership::POWER_MEMBER},
      {:login_type => UserIdentifier::TYPE_EMAIL, :login_value => "foo@bar.com", :power => Membership::POWER_MANAGER} # non-exist user actually
    ]
    assert_equal 1, group.members.count, 'test for set_members failed'
    assert_equal Membership::POWER_MEMBER, group.member_power(member)
    group.set_member_power member, Membership::POWER_MANAGER
    assert_equal Membership::POWER_MANAGER, group.member_power(member)
  end
end