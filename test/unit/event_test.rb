require 'test_helper'

class EventTest < ActiveSupport::TestCase
  include EventsHelper

  setup do
    Event.delete_all
    Instance.delete_all
  end

  test "limit test" do
    (0...10).each do
      begin_time = Time.now + rand(24*60).minutes
      event = Event.new(:name => "TestEvent",
        :begin => begin_time,
        :end => begin_time + rand(180).minutes,
        :creator_id => 0
      );
      event.save
    end

    # OK now
    result1 = query_own_event(0, 1, 0)
    for event in result1
      # do nothing
    end
    assert result1.size == 1

    # OK now
    result2 = query_own_event(0, 1, 0)
    assert result2.size == 1
    # By checking code in ActiveRecord::Relation#size,
    # I find that ActiveRecord::Relation#loaded? is a key. However, I don't know
    # how to fix this bug. This bug is very confusing and can cause big damage!!!
    # This bug has been solved by calling ActiveRecord::Relation#to_a.
  end

  # Replace this with your real tests.
  test "加入刘超的课表" do
    #try load from data
    data = IO.read("test/fixtures/lc.xls")
    class_set = CourseClass.parse_xls_from_data(data)
    #class_set = CourseClass.parse_xls("test/fixtures/lc.xls")
    assert_difference('Event.count', class_set.size) do
      for course_class in class_set
        event = class2event(course_class, 1)
        event.save
      end
    end

    own_events = query_own_event(0, 1000, 1)
    assert own_events.size == class_set.size

    begin_time = Time.parse("2011-2-21 0:0")
    end_time = Time.parse("2011-2-21 23:59")
    monday_instances = query_all_accepted_instance(begin_time, end_time, 1)
    assert monday_instances.size == 1
    assert monday_instances[0].name == "数值分析"

    end_time += 6.days
    first_week_instances = query_all_accepted_instance(begin_time, end_time, 1)
    assert first_week_instances.size == 14-2 # 除去一个双周一个后八周的课程

    end_time += 7.days
    two_week_instances = query_all_accepted_instance(begin_time, end_time, 1)
    assert two_week_instances.size == 14*2-2-2 # 出去两个后八周，一个单周一个双周

    end_time += (14*7).days
    semester_instances = query_all_accepted_instance(begin_time, end_time, 1)
    assert semester_instances.size == 10*16+4*8 # 前八周，后八周，单周，双周
  end
end
