require 'test_helper'

class LyCourseTest < ActionView::TestCase
  include EventsHelper

  setup do
    @course_set = CourseClass.parse_xls("test/fixtures/ly.xls")
  end

  def find_classes(course_name)
    events = []
    @course_set.each do |course_class|
      events << class2event(course_class, 1) if (course_class.name == course_name)
    end
    return events
  end

  test "Three Courses Per Cell" do
    course_name = "游戏心理与策划"
    events = find_classes(course_name)
    assert events.size == 4
    course_name = "游戏影音基础"
    events = find_classes(course_name)
    assert events.size == 4
    course_name = "游戏美术基础"
    events = find_classes(course_name)
    assert events.size == 6
  end

  test "1-4周" do
    course_name = "游戏心理与策划"
    events = find_classes(course_name)
    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule events[0].rrule
    assert rec.count == 4
    assert rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
    assert rec.interval == 1
    assert events[0].begin.localtime == Time.parse("2011-2-26 8:00")
    assert events[0].end.localtime == Time.parse("2011-2-26 9:35")
  end

  test "5-8周" do
    course_name = "游戏影音基础"
    events = find_classes(course_name)
    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule events[0].rrule
    assert rec.count == 4
    assert rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
    assert rec.interval == 1
    assert events[0].begin.localtime == Time.parse("2011-2-26 8:00") + (4*7).days
    assert events[0].end.localtime == Time.parse("2011-2-26 9:35") + (4*7).days
  end

end
