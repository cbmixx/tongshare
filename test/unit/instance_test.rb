require 'test_helper'

class InstanceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "Simple Create" do
    #pp users
    #pp users.class
    #pp users.methods
    #pp users(:one)
    instance = Instance.new(:name => "SimpleInstaceToTestCreatorId", :creator_id => 1)
    instance.save
    assert !Instance.last.creator_id.nil?
  end

  test "test for repeat_until" do
    e = Event.new
    e.name = "test for repeat_until"
    e.rrule_repeat_until = "2011-02-27"
    #assert e.recurrence.repeat_until == Time.parse("2011-02-28") - 1
    e.begin = Time.parse("2011-02-23") + 3600
    e.end = Time.parse("2011-02-23") + 7200
    e.rrule_frequency = GCal4Ruby::Recurrence::DAILY_FREQUENCE
    e.creator_id = 1
    e.save
    assert e.instances.size == 5

    e = Event.new
    e.name = "test for repeat_until"
    e.begin = Time.parse("2011-02-23") + 3600
    e.end = Time.parse("2011-02-23") + 7200
    e.creator_id = 1
    e.rrule_frequency= GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
    e.rrule_days=[3]
    e.rrule_repeat_until = "2011-03-01"
    e.save
    assert e.instances.size == 1
    
    e = Event.new
    e.name = "test for repeat_until"
    e.begin = Time.parse("2011-02-23") + 3600
    e.end = Time.parse("2011-02-23") + 7200
    e.creator_id = 1
    e.rrule_frequency = GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
    e.rrule_days=[3]
    e.rrule_repeat_until = "2011-03-02"
    e.save
    assert e.instances.size == 2
  end
end
