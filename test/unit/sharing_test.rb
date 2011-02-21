require 'test_helper'

class SharingTest < ActiveSupport::TestCase
  include EventsHelper
  fixtures :user_identifiers
  fixtures :users
  fixtures :events

  setup do
    Sharing.delete_all
    UserSharing.delete_all
    Instance.delete_all
  end

  test "for add_sharing, decide_by_user, basic" do
    events(:one_instance).save
    assert events(:one_instance).instances.size == 1
    #hack
    events(:weekly_count).rrule_days=([3])
    events(:weekly_count).rrule_count = 5
    events(:weekly_count).save
    assert events(:weekly_count).instances.size == 5
    #open_to_user
    assert events(:one_instance).open_to_user?(1)
    assert !events(:one_instance).open_to_user?(2)
    acc = Acceptance.new(:event_id => 1, :user_id => 2, :decision => true)
    acc.save
    assert events(:one_instance).open_to_user?(2)
    acc.destroy
    #add_sharing
    #hashs = []
    #user_identifiers(:em_one, :em_two, :email_one, :email_two, :mo_one, :mo_two).each do |uid|
    #  hashs << {:login_value => uid.login_value, :login_type => uid.login_type}
    #end
    ret = events(:one_instance).add_sharing(1, "extra", [1, 2, 3, 4, 1, 2])
    #pp ret
    assert ret

    assert events(:one_instance).open_to_user?(2)
    
    #pp events(:one_instance).sharings
    ret = events(:one_instance).sharings.to_a[0].user_sharings.to_a
    #pp ret.size
    assert ret.size == 2
    assert ret[0].user_id == 1
    assert ret[1].user_id == 2

    #decide_by_user, accept
    assert_nil ret[1].accept?
    assert events(:one_instance).decide_by_user(2, true)
    assert ret[1].accept?
    assert events(:one_instance).decide_by_user(2, false)
    assert !ret[1].accept?

    #query series
    time_begin = Time.parse('2011-01-19 00:00:00')
    time_end = Time.parse('2011-05-19 00:00:00')
    ret = query_all_accepted_instance_includes_event(time_begin, time_end, 2)
    assert ret.size == 5 # event #2 * 5
    events(:one_instance).decide_by_user(2, true)
    ret = query_all_accepted_instance_includes_event(time_begin, time_end, 2)
    assert ret.size == 6 # event #1 + event #2 * 5
    count_i = 0
    count_j = 0
    ret.each do |r|
      count_i += 1 if r.event == events(:one_instance)
      count_j += 1 if r.event == events(:weekly_count)
    end
    assert count_i == 1
    assert count_j == 5
  end
  
end
