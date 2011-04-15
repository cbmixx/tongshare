require 'test_helper'

class GroupsHelperTest < ActionView::TestCase
  test 'public group test' do
    user5 = User.find(5)
    user6 = User.find(6)
    g = query_or_create_public_group("test", user5)
    assert g
    g = query_or_create_public_group("test", user6)
    assert g.creator_id == 5
    g.set_members([{:user_id => 1, :power => Membership::POWER_MEMBER},
        {:user_id => 2, :power => Membership::POWER_MEMBER},
        {:user_id => 3, :power => Membership::POWER_MEMBER}])
    pp g.members
    g.set_managers([{:user_id => 1}, {:login_type => UserIdentifier::TYPE_EMAIL, :login_value => "foo3@bar.com"}])
    managers = g.managers
    assert managers.count == 2
    assert managers[0].id == 1
    assert managers[1].id == 3
    assert g.members.count == 3
    g.set_managers([{:user_id => 2}])
    managers = g.managers
    assert managers.count == 1
    assert managers[0].id == 2
    assert g.members.count == 3
  end
end
