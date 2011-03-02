require 'test_helper'

class ReminderTest < ActiveSupport::TestCase
  fixtures :events
  setup do
    Instance.delete_all
    Reminder.delete_all
    ReminderQueue.delete_all
  end

  test "basic test" do
    e = events(:one_instance)
    e.save
    e.add_reminder(1, Reminder::TIME_DAY, Reminder::METHOD_EMAIL)
    assert e.reminders.first.reminder_queues.size == 0
    e.end = Time.now + 2.day + (e.end - e.begin)
    e.begin = Time.now + 2.day
    e.save
    assert e.reminders.first.reminder_queues.size == 1
    e.begin = Time.parse("2011-01-01")
    e.end = Time.parse("2011-01-02")
    e.save
    assert e.reminders.first.reminder_queues.size == 0
  end
end
