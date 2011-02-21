# Author:: Mike Reich (mike@seabourneconsulting.com)
# Copyright:: Copyright (C) 2010 Mike Reich
# License:: GPL v2
#--
# Licensed under the General Public License (GPL), Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# Feel free to use and update, but be sure to contribute your
# code back to the project and attribute as required by the license.
#++
require 'time'
class Time
  #Returns a ISO 8601 complete formatted string of the time
  def complete
    #self.utc.iso8601
    self.utc.strftime("%Y%m%dT%H%M%SZ")
  end
  
  def self.parse_complete(value)
    
	  #Time.xmlschema(value)
    d, h = value.split("T")
    if (h == nil)
      return Time.parse(d)
    else
      if h["Z"]
        #FIXME timezone!
        return Time.parse(d+" "+h.gsub("Z","")) + Time.now.utc_offset
      else
        return Time.parse(value)
      end
    end
  end
end

module GCal4Ruby
  #The Recurrence class stores information on an Event's recurrence.  The class implements
  #the RFC 2445 iCalendar recurrence description.
  class Recurrence
    NONE_FREQUENCY = "NONE"   #add this to represent "no repeat"
    DAILY_FREQUENCE = "DAILY"
    WEEKLY_FREQUENCE = "WEEKLY"

    FREQUENCES = [DAILY_FREQUENCE, WEEKLY_FREQUENCE]
    DUMMY_FREQS = FREQUENCES + [NONE_FREQUENCY]

    #The event start date/time
    attr_reader :start_time
    #The event end date/time
    attr_reader :end_time
    #the event reference
    attr_reader :event
    #The date until which the event will be repeated
    attr_reader :repeat_until
    #The event frequency
    attr_reader :frequency
    #True if the event is all day (i.e. no start/end time)
    attr_accessor :all_day
    #
    attr_accessor :interval
    #
    attr_reader :day
    #
    attr_accessor :count
    
    #Accepts an optional attributes hash or a string containing a properly formatted ISO 8601 recurrence rule.  Returns a new Recurrence object
    def initialize(vars = {})
      @interval = 1
      if vars.is_a? Hash
        vars.each do |key, value|
          self.send("#{key}=", value)
        end
      elsif vars.is_a? String
        self.load(vars)
      end
      @all_day ||= false
    end
    
    #Accepts a string containing a properly formatted ISO 8601 recurrence rule and loads it into the recurrence object.  
    #Contributed by John Paul Narowski.

    WEEK = ["SU", "MO", "TU", "WE", "TH", "FR", "ST"]
    WEEK_REVERSE = {"SU" => 0, "MO" => 1, "TU" => 2, "WE" => 3, "TH" => 4, "FR" => 5, "ST" => 6}
    def load(rec)
      got_start = false 
      attrs = rec.split("\n")
      attrs.each do |val|
        key, value = val.split(":")
        if key == 'RRULE'
          value.split(";").each do |rr| 
            rr_key, rr_value = rr.split("=")
            if rr_key == 'FREQ'
              @frequency = rr_value
            elsif rr_key == 'INTERVAL'
              @interval = rr_value.to_i
            elsif rr_key == 'COUNT'
              @count = rr_value.to_i
            elsif rr_key == 'UNTIL'
              @repeat_until = Time.parse_complete(rr_value)
            elsif rr_key == 'BYDAY' or rr_key == 'BYMONTHDAY'
              @day = []
              rr_value.split(",").each do |d|
                @day[WEEK_REVERSE[d.upcase]] = true;
              end
            end
          end

        elsif !got_start and (key.include?("DTSTART;TZID") or key.include?("DTSTART") or key.include?('DTSTART;VALUE=DATE-TIME'))
          @start_time = Time.parse_complete(value)
          got_start = true
        elsif key.include?('DTSTART;VALUE=DATE')
          @start_time = Time.parse(value)
          @all_day = true
        elsif key.include?("DTEND;TZID") or key.include?("DTEND") or key.include?('DTEND;VALUE=DATE-TIME')
          @end_time = Time.parse_complete(value)
        elsif key.include?('DTEND;VALUE=DATE')
          @end_time = Time.parse(value)
        end
      end
    end

    # Check whether there is RRULE before load
    def from_rrule(s)
      if (!s.start_with? "RRULE:")
        load('RRULE:' + s)
      else
        load s
      end
    end

    def rrule

      #add by Wander
      return "" if @frequency.nil?

      output = ''
      output += "RRULE:FREQ=#{@frequency}"
      output += ";COUNT=#{@count}" if count
      output += ";INTERVAL=#{@interval}" if interval > 1
      #TODO: BYMONTHDAY
      
      if @day && @day.include?(true)
        output += ";BYDAY="
        t = false
        for i in 0 .. 6
          if @day[i]
            output += "," if t
            output += WEEK[i]
            t = true
          end
        end
      end
      if @repeat_until
        if @all_day
          output += ";UNTIL=#{@repeat_until.strftime("%Y%m%d")}"
        else
          output += ";UNTIL=#{@repeat_until.complete}"
        end
      end
      output
    end

    #Returns a string with the correctly formatted ISO 8601 recurrence rule
    def to_recurrence_string
      output = ''
      if @all_day
        output += "DTSTART;VALUE=DATE:#{@start_time.utc.strftime("%Y%m%d")}\n"
      else
        output += "DTSTART;VALUE=DATE-TIME:#{@start_time.complete}\n"
      end
      if @all_day
        output += "DTEND;VALUE=DATE:#{@end_time.utc.strftime("%Y%m%d")}\n"
      else
        output += "DTEND;VALUE=DATE-TIME:#{@end_time.complete}\n"
      end
      output += rrule 
      output += "\n"
    end
    
    #Sets the start date/time.  Must be a Time object.
    def start_time=(s)
      if not s.is_a?(Time)
        raise RecurrenceValueError, "Start must be a date or a time"
      else
        @start_time = s
      end
    end
    
    #Sets the end Date/Time. Must be a Time object.
    def end_time=(e)
      if not e.is_a?(Time)
        raise RecurrenceValueError, "End must be a date or a time"
      else
        @end_time = e
      end
    end
    
    #Sets the parent event reference
    def event=(e)
      if not e.is_a?(Event)
        raise RecurrenceValueError, "Event must be an event"
      else
        @event = e
      end
    end
    
    #Sets the end date for the recurrence
    def repeat_until=(r)
      if r.is_a?(Date)
        if !@start_time.nil?
          delta = r - @start_time.to_date
          @repeat_until = @start_time + delta
        else
          #TODO offset?
          @repeat_until = r.to_time
        end
      elsif r.is_a?(Time)
        @repeat_until = r
      else
        raise RecurrenceValueError, "Repeat_until must be a date or a time"
      end
    end

    # Set frequency. f must be one String in FREQUENCES
    def frequency=(f)

      if f.is_a?(String) && FREQUENCES.include?(f)
        @frequency = f
      elsif f.nil? || f == NONE_FREQUENCY
        @frequency = nil  #add by Wander
      else
        raise RecurrenceValueError, "Frequency must be a string (see documentation)"
      end
    end

    def interval=(i)
      if i.is_a?(Integer) && i >= 1
        @interval = i
      else
        raise RecurrenceValueError, "Interval must be a Integer and greater than 1"
      end

    end

    # days must be an array of Integers
    # days[i]%7 will be added to event.day
    def set_days(days)
      @day = Array.new(7, false)
      for d in days
        @day[d%7] = true
      end
    end

    #[day%7] will be setted to event.day
    def set_day(day)
      days = [day]
      set_days(days)
    end

    def get_days
      days = []
      for i in 0..6
        days << i if (!@day.nil? && @day[i])
      end
      days
    end
  end
end
