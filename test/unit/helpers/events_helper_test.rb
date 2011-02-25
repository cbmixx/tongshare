require 'test_helper'

class EventsHelperTest < ActionView::TestCase
  setup do
    @course_set = CourseClass.parse_xls("test/fixtures/lc.xls")
  end

  def find_classes(course_name)
    events = []
    @course_set.each do |course_class|
      events << class2event(course_class, 1) if (course_class.name == course_name)
    end
    return events
  end
  
  test "全周单时" do
    course_name = "计算机图形学基础"
    events = find_classes(course_name)
    assert events.size == 1
    assert events[0].name == course_name
    assert events[0].begin.localtime == Time.parse("2011-2-23 8:00")
    assert events[0].end.localtime == Time.parse("2011-2-23 9:35")
    assert events[0].location == "六教6A017"
    assert events[0].extra_info == "胡事民；限选；全周；六教6A017"

    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule(events[0].rrule)
    assert rec.count == 16
    assert rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
    assert rec.interval == 1
    assert rec.day[3]
    for i in 0...7
      assert !rec.day[i] if i != 3
    end
  end

  test "一门课程全周+双周" do
    course_name = "数值分析"
    events = find_classes(course_name)
    assert events.size == 2
    begins = ["2011-2-21 8:00", "2011-3-3 15:20"]
    ends = ["2011-2-21 9:35", "2011-3-3 16:55"]
    extra_infos = ["喻文健；限选；全周；六教6C201", "喻文健；限选；双周；六教6C201"]
    week_days = [1, 4]
    intervals = [1, 2]
    for  i in 0...2 
      assert events[i].name == course_name
      assert events[i].location == "六教6C201"
      assert events[i].extra_info == extra_infos[i]
      assert events[i].begin.localtime == Time.parse(begins[i])
      assert events[i].end.localtime == Time.parse(ends[i])
      rec = GCal4Ruby::Recurrence.new
      rec.from_rrule(events[i].rrule)
      assert rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
      assert rec.day[week_days[i]]
      for day in 0...7
        assert !rec.day[day] if day != week_days[i]
      end
      assert rec.interval == intervals[i]
    end
  end

  test "前八周单时" do
    course_name = "计算机软件前沿技术"
    events = find_classes(course_name)
    assert events.size == 1
    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule(events[0].rrule)
    assert(rec.count == 8)
    assert(rec.interval == 1)
    assert(rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE)
    assert(events[0].begin.localtime == Time.parse("2011-2-22 15:20"))
  end

  test "后八周单时" do
    course_name = "后八周测试课程"
    events = find_classes(course_name)
    assert events.size == 1
    assert events[0].begin.localtime == Time.parse("2011-2-26 9:50") + (8*7).days
    assert events[0].end.localtime == Time.parse("2011-2-26 11:25") + (8*7).days
    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule(events[0].rrule)
    assert(rec.count == 8)
    assert(rec.interval == 1)
    assert(rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE)
  end

  test "单周单时" do
    course_name = "单周测试课程"
    events = find_classes(course_name)
    assert events.size == 1
    assert events[0].begin.localtime == Time.parse("2011-2-27 13:30")
    assert events[0].end.localtime == Time.parse("2011-2-27 15:05")
    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule(events[0].rrule)
    assert(rec.count == 8)
    assert(rec.interval == 2)
    assert(rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE)
  end

  test "No Week Modifier" do
    course_name = "NO MODIFIER 测试课程"
    events = find_classes(course_name)
    assert events.size == 1
    assert events[0].begin.localtime == Time.parse("2011-2-25 19:20")
    assert events[0].end.localtime == Time.parse("2011-2-25 20:55")
    rec = GCal4Ruby::Recurrence.new
    rec.from_rrule(events[0].rrule)
    assert(rec.count == 16)
    assert(rec.interval == 1)
    assert(rec.frequency == GCal4Ruby::Recurrence::WEEKLY_FREQUENCE)
  end

  test "重复" do
    event = Event.new
    assert show_friendly_rrule(event) == ""
    event.rrule = ""
    assert show_friendly_rrule(event) == ""
    rec = GCal4Ruby::Recurrence.new
    rec.frequency = GCal4Ruby::Recurrence::WEEKLY_FREQUENCE
    rec.set_day(0)
    event.rrule = rec.rrule
    assert show_friendly_rrule(event) == "每周的周日"
    rec.set_days([1, 3])
    rec.count = 10
    event.rrule = rec.rrule
    assert show_friendly_rrule(event) == "每周的周一、三，共10次"
    rec.interval = 2
    event.rrule = rec.rrule
    assert show_friendly_rrule(event) == "每2周的周一、三，共10次"
    rec.frequency = GCal4Ruby::Recurrence::DAILY_FREQUENCE
    rec.repeat_until = Time.parse("2011-7-9").to_date
    rec.count = nil
    rec.interval = 1
    event.rrule = rec.rrule
#    pp show_friendly_rrule(event)
    assert show_friendly_rrule(event) == "每天，至2011-07-09"
    rec.interval = 3
    event.rrule = rec.rrule
#    pp show_friendly_rrule(event)
    assert show_friendly_rrule(event) == "每3天，至2011-07-09"
  end

  test "TEST RANGE" do
    from = Time.now.beginning_of_day + 8*3600
    to = from + 3600*2
#    pp friendly_time_range(from, to)
    assert friendly_time_range(from, to) == "08:00 - 10:00"
    to += 24*3600
#    pp friendly_time_range(from, to)
    assert friendly_time_range(from, to) == "08:00 - 明天 10:00"
    from += 3600*24
#    pp friendly_time_range(from, to)
    assert friendly_time_range(from, to) == "明天 08:00 - 10:00"
    from += 2*3600*24
    to += 2*3600*24
#    pp friendly_time_range(from, to)
    assert friendly_time_range(from, to) != "大后天 08:00 - 10:00"
    from = Time.parse("1989-7-9")
    to = from + 1.day
#    pp friendly_time_range(from, to)
    assert friendly_time_range(from, to) == "1989年7月09日(周日) 00:00 - 1989年7月10日(周一) 00:00"
    from = Time.parse("2011-12-31")
    to = Time.parse("2012-1-1")
#    pp friendly_time_range(from, to)
    assert friendly_time_range(from, to) == "12月31日(周六) 00:00 - 2012年1月01日(周日) 00:00"
  end
end
