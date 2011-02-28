#!/usr/bin/ruby
require 'rubygems'
require 'parseexcel'
require 'iconv'
require 'pp'
require 'tempfile'

# First use xls2table to convert a xls file to a 2D array, i.e. table.
# Then use CourseClass.parse_table(table) which returns a class_set.
# A class_set is an array of CourseClass
class CourseClass
  ALL_WEEK = "全周"
  EVEN_WEEK = "双周"
  ODD_WEEK = "单周"
  EARLIER_EIGHT = "前八周"
  LATER_EIGHT = "后八周"

  VALID_WEEK_MODIFIERS = [ALL_WEEK, EVEN_WEEK, ODD_WEEK, EARLIER_EIGHT, LATER_EIGHT]
  VALID_SECOND_ROW = ",星期一,星期二,星期三,星期四,星期五,星期六,星期日"

  COURSE_REGEX = /(.*)\((.*)\)/
  SPECIAL_WEEK_MODIFIER_REGEX = /(\d+)-(\d+)周/
  SUPER_SPECIAL_WEEK_MODIFIER_REGEX = /第([\d,-]+)周+/

  attr_accessor :class_set
  attr_accessor :name
  attr_accessor :teacher
  attr_accessor :location
  #day_time和week_day
  #共同确定课程中一节课的时间（一门课一周可能有多节）
  attr_accessor :day_time # 1..6, 第1..6节
  attr_accessor :week_day # 1..7，星期一..星期日
  attr_accessor :week_modifier # "全周", "双周", "单周", "前八周", "后八周", "x-y周"
  attr_accessor :extra_info # 所有除课程名之外的信息，如“喻文健；限选；全周；六教6C201”

  def initialize(class_set = [])
    @class_set = class_set
    @name = "Default Course Name"
    @week_days = []
    @day_times = []
  end

  def self.add(week_day, day_time, spec, class_set)
    for result in spec.scan COURSE_REGEX
      name = result[0];
      extra = result[1];
      course_class = CourseClass.new(class_set)
      course_class.name = name
      course_class.extra_info = extra
      options = extra.split("；")
      course_class.teacher = options.first
      course_class.location = options.last
      for i in 1...options.size-1
        if (m = options[i].match SUPER_SPECIAL_WEEK_MODIFIER_REGEX)
          week_specs = m[1].split(',')
          course_class.week_modifier = options[i]
          course_class.location = options.first
          course_class.teacher = ""
          course_class.day_time = day_time
          course_class.week_day = week_day
          for week_spec in week_specs
            special_class = course_class.dup
            if (week_spec.match /\d+-\d+/)
              special_class.week_modifier = week_spec + "周"
            else
              special_class.week_modifier = week_spec + '-' + week_spec + "周"
            end
            class_set << special_class
          end
          return
        end
        course_class.week_modifier = options[i] if VALID_WEEK_MODIFIERS.include? options[i]
        course_class.week_modifier = options[i] if options[i].match SPECIAL_WEEK_MODIFIER_REGEX
      end
      course_class.day_time = day_time
      course_class.week_day = week_day
      class_set << course_class
    end
  end

  def self.parse_xls_from_data(data)
    tf = Tempfile.new "xls_temp_"
    tf.write data
    tf.close
    ret = parse_xls(tf.path)
    tf.unlink
    ret
  end
  # Just Course.parse_table(xls2table(filename))
  def self.parse_xls(filename)
    table = xls2table(filename)
    return self.parse_table(table)
  end

  # Returns an array of CourseClass (there might be two CourseClasses in this array with the same name,
  # because one course might have multiple classes per week
  def self.parse_table(table)
    #check table first, a sample valid csv table is like
    #
    #  ,,,,实验课课表
    #,星期一,星期二,星期三,星期四,星期五,星期六,星期日
    #第1节,数值分析(喻文健；限选；全周；六教6C201),,计算机图形学基础(胡事民；限选；全周；六教6A017),,密码学及安全计算(陈震；限选；全周；六教6A309),,
    #第2节,,,计算机网络原理(吴建平；必修；全周；一教201),计算机系统结构(汪东升；必修；全周；六教6A017),毛泽东思想和中国特色社会主义理论体系概论(冯务中；必修；全周；一教104),,
    #第3节,,三年级男生网球(刘波；全周；综合馆西网球场),软件工程(白晓颖；限选；全周；四教4305),,,,
    #第4节,,计算机软件前沿技术(蔡懿慈；限选；前八周；六教6A113),软件工程(白晓颖；限选；全周；四教4305),数值分析(喻文健；限选；双周；六教6C201),,,
    #第5节,,,,,,,
    #第6节,,,,,,,
    valid_table = (table.size >= 8 && table[1].join(',') == VALID_SECOND_ROW);
    if (!valid_table) # TODO raise Exception
      puts "Not a valid table! Your table is:"
      pp table
      return nil
    end
    class_set = []
    for day_time in 1..6
      for week_day in 1..7
        row_index = day_time+2-1
        col_index = week_day+1-1
        spec = table[row_index][col_index]
        self.add(week_day, day_time, spec, class_set) if spec
      end
    end
    return class_set
  end
end

def xls2table(filename)
  result = []
  xls = Spreadsheet::ParseExcel.parse(filename)
  sheet = xls.worksheet(0)
  sheet.each do |row|
    parsed_row = []
    row.each do |cell|
      if (cell)
        str = Iconv.iconv('utf-8', cell.encoding, cell.to_s)[0]
      else
        str = nil
      end
      parsed_row << str
    end
    result << parsed_row
  end
  return result
end

