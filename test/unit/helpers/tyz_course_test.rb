require 'test_helper'

class TyzCourseTest < ActionView::TestCase
  include EventsHelper

  setup do
    @course_set = CourseClass.parse_xls("test/fixtures/tyz.xls")
  end

  def find_classes(course_name)
    events = []
    @course_set.each do |course_class|
      events << class2event(course_class, 1) if (course_class.name == course_name)
    end
    return events
  end

  test "物理实验" do
    events = find_classes("物理实验B（2）双一下AA")
    pp events.size
    assert events.size == 10
    assert events[0].location == "六教5-7层"
    assert events[0].begin.localtime == Time.parse("2011-2-21 13:30") + 5.weeks
#    pp events[9].end.localtime
#    pp Time.parse("2011-2-21 16:50") + 13.weeks
    assert events[9].end.localtime == Time.parse("2011-2-21 16:50") + 13.weeks
  end

  test "电子技术实验" do
    events = find_classes("电子技术实验DC93")
    assert events.size == 3
    assert events[0].location == "东主楼9-304"
    assert events[0].begin.localtime == Time.parse("2011-2-24 13:00") + 5.weeks
    assert events[1].end.localtime == Time.parse("2011-2-24 15:15") + 8.weeks
    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule(events[2].rrule)
    assert rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
    assert rec.interval == 1
    assert rec.count == 5
  end

  test "JAVA" do
    events = find_classes("Java语言程序设计FZ1")
    assert events.size == 1
    assert events[0].location == "东主楼9区224室"
    assert events[0].begin.localtime == Time.parse("2011-2-25 15:20")+1.week
    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule(events[0].rrule)
    assert rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
    assert rec.interval == 1
    assert rec.count == 15
  end
end
