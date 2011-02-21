require 'test_helper'
require 'rails/performance_test_help'
require 'gcal4ruby'

class InstanceTest < ActionDispatch::PerformanceTest
  include EventsHelper

  USER_NUM = 10
  EVENT_NUM = 10
  QUERY_REPEAT = 100
  REC = false

  def test_performance
    Event.delete_all
    Instance.delete_all

    assert_difference('Event.count', USER_NUM * EVENT_NUM) do
      for user_id in 0...USER_NUM
        for event_i in 0...EVENT_NUM
          begin_time = Time.now + rand(24*60).minutes
          event = Event.new(:name => "TestEvent",
            :begin => begin_time,
            :end => begin_time + rand(180).minutes,
            :creator_id => user_id
          );
          if (REC)
            rec = GCal4Ruby::Recurrence.new
            rec.frequency = GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
            rec.set_day(rand(7))
            rec.count = rand(16)+1
            event.rrule = rec.rrule
          end
          event.save
        end
      end
    end

    (0...QUERY_REPEAT).each do
      for user_id in 0...USER_NUM
        query_own_event_test1(user_id)
        query_own_event_test1000(user_id)
      end
    end
  end

end

def query_own_event_test1(user_id)
  result = query_own_event(0, 1, user_id)
  size = 0
  for event in result
    size += 1
  end
  assert size == 1
end

def query_own_event_test1000(user_id)
  result = query_own_event(0, 1000, user_id)
  size = 0
  for event in result
    size += 1
  end
  assert size == InstanceTest::EVENT_NUM
end

